#!/usr/bin/env python3
"""Finite macOS installer for the Miter PeTTa/MeTTa runtime.

This program is packaging machinery.  It validates and installs bytes, then
exits; it is never imported by or resident beside Miter's cognitive cycle.
"""

from __future__ import annotations

import argparse
import getpass
import hashlib
import json
import os
import pathlib
import platform
import pwd
import secrets
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request


SOURCE_ROOT = pathlib.Path(__file__).resolve().parent
CONFIG_PATH = SOURCE_ROOT / "config" / "miter.json"
LAUNCHD_LABEL = "io.singularitynet.miter"
LAUNCHD_PATH = pathlib.Path("/Library/LaunchDaemons") / f"{LAUNCHD_LABEL}.plist"
OPERATOR_PATH = pathlib.Path("/usr/local/bin/miter")
APPLICATION_MEMBERS = (
    "CONSTITUTION.md",
    "LICENSE",
    "MITER_BUILD_ATLAS.md",
    "MITER_SOUL_CONSTITUTIVE_SPEC.md",
    "README.md",
    "install_miter.py",
    "authority",
    "bin",
    "config",
    "constitution",
    "effect_membranes",
    "src",
)
DURABLE_RUNTIME_DIRECTORIES = (
    "inbox", "leased", "consumed", "rejected", "store", "checkpoints",
    "continuity", "receipts", "outbox", "proofs", "intents", "model",
    "surface", "semantic", "workspace", "capabilities",
)
DURABLE_RUNTIME_FILES = (
    "evaluation-grants.json", "model-direction.json", "model-grants.json",
)


class InstallError(RuntimeError):
    pass


def run(argv: list[str], *, check: bool = True, capture: bool = True,
        user: str | None = None, env: dict[str, str] | None = None,
        cwd: pathlib.Path | str | None = None) -> subprocess.CompletedProcess[str]:
    command = list(argv)
    if user is not None and os.geteuid() == 0 and user != "root":
        command = ["/usr/bin/sudo", "-u", user, "-H", *command]
    return subprocess.run(
        command,
        check=check,
        stdin=None,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
        text=True,
        env=env,
        cwd=cwd,
    )


def load_config() -> dict:
    try:
        document = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise InstallError(f"Cannot read {CONFIG_PATH}: {exc}") from exc
    deployment = document.get("deployment")
    if not isinstance(deployment, dict) or deployment.get("schema") != "miter-installation-v1":
        raise InstallError("config/miter.json has no valid deployment section")
    if deployment.get("runtime_user") != "claritymiter":
        raise InstallError("The dedicated runtime identity must be claritymiter")
    return document


def command_path(name: str) -> str:
    found = shutil.which(name)
    if not found:
        raise InstallError(f"Required host command is unavailable: {name}")
    return found


def source_identity() -> str:
    git = shutil.which("git")
    if git and (SOURCE_ROOT / ".git").exists():
        status = run([git, "status", "--porcelain"], check=True).stdout.strip()
        if status:
            raise InstallError("Installer refuses an uncommitted application source tree")
        head = run([git, "rev-parse", "HEAD"], check=True).stdout.strip()
        if len(head) == 40:
            return head
    digest = hashlib.sha256()
    for member in APPLICATION_MEMBERS:
        root = SOURCE_ROOT / member
        paths = [root] if root.is_file() else sorted(path for path in root.rglob("*") if path.is_file())
        for path in paths:
            relative = path.relative_to(SOURCE_ROOT).as_posix().encode()
            digest.update(len(relative).to_bytes(4, "big"))
            digest.update(relative)
            data = path.read_bytes()
            digest.update(len(data).to_bytes(8, "big"))
            digest.update(data)
    return digest.hexdigest()


def require_supported_host() -> None:
    if sys.platform != "darwin":
        raise InstallError("This installer currently supports macOS only")
    if platform.machine() != "arm64":
        raise InstallError("The current native store extension requires Apple Silicon")
    swipl = command_path("swipl")
    version = run([swipl, "--version"]).stdout.strip()
    try:
        number = version.split("version", 1)[1].strip().split(".")
        major, minor = int(number[0]), int(number[1])
    except (IndexError, ValueError) as exc:
        raise InstallError(f"Cannot parse SWI-Prolog version: {version}") from exc
    if (major, minor) < (9, 3):
        raise InstallError(f"Miter requires SWI-Prolog 9.3 or newer; found {version}")
    command_path("swipl-ld")
    docker = command_path("docker")
    run([docker, "compose", "version"])


def runtime_account(name: str) -> pwd.struct_passwd | None:
    try:
        return pwd.getpwnam(name)
    except KeyError:
        return None


def ensure_runtime_account(name: str) -> pwd.struct_passwd:
    account = runtime_account(name)
    if account is None:
        if os.geteuid() != 0:
            raise InstallError(f"Run install with sudo so it can create the {name} identity")
        print(f"Creating the non-admin {name} runtime identity.")
        print("macOS will privately prompt for that account's password; it is not captured by this installer.")
        run([
            "/usr/sbin/sysadminctl", "-addUser", name,
            "-fullName", "Miter Runtime", "-home", f"/Users/{name}",
            "-shell", "/bin/zsh", "-password", "-",
        ], capture=False)
        account = runtime_account(name)
    if account is None:
        raise InstallError(f"The {name} identity could not be established")
    if account.pw_dir != f"/Users/{name}":
        raise InstallError(f"Unexpected home for {name}: {account.pw_dir}")
    admin = run(["/usr/bin/id", "-Gn", name]).stdout.split()
    if "admin" in admin:
        raise InstallError(f"{name} must remain a non-admin runtime identity")
    return account


def sha256_file(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def safe_extract_tar(archive: pathlib.Path, destination: pathlib.Path) -> pathlib.Path:
    destination.mkdir(parents=True, exist_ok=False)
    with tarfile.open(archive, "r:gz") as bundle:
        members = bundle.getmembers()
        roots = {member.name.split("/", 1)[0] for member in members if member.name}
        if len(roots) != 1:
            raise InstallError("Pinned PeTTa archive has an unexpected root layout")
        root_name = next(iter(roots))
        for member in members:
            target = (destination / member.name).resolve()
            if destination.resolve() not in target.parents and target != destination.resolve():
                raise InstallError("Pinned PeTTa archive contains a path traversal")
            if member.issym() or member.islnk() or member.isdev():
                raise InstallError("Pinned PeTTa archive contains an unsupported link or device")
        bundle.extractall(destination)
    extracted = destination / root_name
    if not (extracted / "src" / "main.pl").is_file():
        raise InstallError("Pinned PeTTa archive does not contain src/main.pl")
    return extracted


def install_petta(deployment: dict) -> pathlib.Path:
    pin = deployment["petta"]["commit"]
    dependency_root = pathlib.Path(deployment["dependency_root"])
    target = dependency_root / "PeTTa" / pin
    if (target / "src" / "main.pl").is_file():
        return target
    dependency_root.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="miter-petta-install.") as temporary:
        temporary_path = pathlib.Path(temporary)
        archive = temporary_path / "petta.tar.gz"
        try:
            with urllib.request.urlopen(deployment["petta"]["archive_url"], timeout=60) as source, \
                    archive.open("wb") as output:
                shutil.copyfileobj(source, output)
        except (OSError, urllib.error.URLError) as exc:
            raise InstallError(f"Cannot acquire pinned PeTTa: {exc}") from exc
        actual = sha256_file(archive)
        expected = deployment["petta"]["archive_sha256"]
        if actual != expected:
            raise InstallError(f"Pinned PeTTa archive hash mismatch: {actual}")
        unpack = temporary_path / "unpacked"
        extracted = safe_extract_tar(archive, unpack)
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            raise InstallError(f"Incomplete PeTTa destination already exists: {target}")
        shutil.copytree(extracted, target)
    make_read_only_tree(target)
    return target


def make_read_only_tree(root: pathlib.Path) -> None:
    for path in [root, *root.rglob("*")]:
        if path.is_symlink():
            raise InstallError(f"Installed application contains an unsupported symlink: {path}")
        if path.is_dir():
            path.chmod(0o755)
        elif path.is_file():
            executable = path.name in {"miter", "install_miter.py"} or bool(path.stat().st_mode & stat.S_IXUSR)
            path.chmod(0o755 if executable else 0o644)
        if os.geteuid() == 0:
            os.chown(path, 0, 0)


def install_application(deployment: dict, identity: str) -> pathlib.Path:
    releases = pathlib.Path(deployment["application_root"]) / "releases"
    target = releases / identity
    if target.is_dir():
        return target
    releases.mkdir(parents=True, exist_ok=True)
    staging = releases / f".{identity}.installing-{os.getpid()}"
    if staging.exists():
        raise InstallError(f"Application staging path already exists: {staging}")
    staging.mkdir()
    try:
        for member in APPLICATION_MEMBERS:
            source = SOURCE_ROOT / member
            destination = staging / member
            if source.is_dir():
                shutil.copytree(source, destination)
            elif source.is_file():
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, destination)
            else:
                raise InstallError(f"Required application member is missing: {source}")
        make_read_only_tree(staging)
        staging.rename(target)
    except Exception:
        if staging.exists():
            shutil.rmtree(staging)
        raise
    return target


def endpoint_available(url: str) -> bool:
    try:
        with urllib.request.urlopen(url, timeout=3) as response:
            return 200 <= response.status < 500
    except (OSError, urllib.error.URLError):
        return False


def render_compose(config: dict, postgres_password: str) -> str:
    deployment = config["deployment"]
    mattermost_port = urllib.parse.urlparse(config["mattermost"]["origin"]).port or 8065
    chroma_port = urllib.parse.urlparse(config["memory"]["chroma"]["origin"]).port or 8000
    images = deployment["images"]
    return f'''services:
  chroma:
    image: "{images['chroma']}"
    restart: unless-stopped
    security_opt: ["no-new-privileges:true"]
    ports: ["127.0.0.1:{chroma_port}:8000"]
    volumes: ["./volumes/chroma:/data"]
  postgres:
    image: "{images['postgres']}"
    restart: unless-stopped
    security_opt: ["no-new-privileges:true"]
    environment:
      POSTGRES_USER: miter
      POSTGRES_PASSWORD: "{postgres_password}"
      POSTGRES_DB: mattermost
    volumes: ["./volumes/postgres:/var/lib/postgresql/data"]
  mattermost:
    image: "{images['mattermost']}"
    restart: unless-stopped
    depends_on: [postgres]
    security_opt: ["no-new-privileges:true"]
    ports: ["127.0.0.1:{mattermost_port}:8065"]
    environment:
      MM_SQLSETTINGS_DRIVERNAME: postgres
      MM_SQLSETTINGS_DATASOURCE: "postgres://miter:{postgres_password}@postgres:5432/mattermost?sslmode=disable&connect_timeout=10"
      MM_SERVICESETTINGS_SITEURL: "{config['mattermost']['origin']}"
      MM_SERVICESETTINGS_ENABLELOCALMODE: "true"
      MM_BLEVESETTINGS_INDEXDIR: /mattermost/bleve-indexes
    volumes:
      - ./volumes/mattermost/config:/mattermost/config
      - ./volumes/mattermost/data:/mattermost/data
      - ./volumes/mattermost/logs:/mattermost/logs
      - ./volumes/mattermost/plugins:/mattermost/plugins
      - ./volumes/mattermost/client-plugins:/mattermost/client/plugins
      - ./volumes/mattermost/bleve-indexes:/mattermost/bleve-indexes
'''


def invoking_user(runtime_user: str) -> str:
    candidate = os.environ.get("SUDO_USER") or getpass.getuser()
    return candidate if candidate != "root" else runtime_user


def install_services(config: dict, *, reuse: bool) -> str:
    deployment = config["deployment"]
    mattermost = config["mattermost"]["origin"] + "/api/v4/system/ping"
    chroma = config["memory"]["chroma"]["origin"] + "/api/v2/heartbeat"
    occupied = [name for name, url in (("Mattermost", mattermost), ("Chroma", chroma)) if endpoint_available(url)]
    if reuse:
        if len(occupied) != 2:
            raise InstallError("Existing-service migration requires healthy loopback Mattermost and Chroma")
        return "reused-explicitly-existing-local-services"
    services_root = pathlib.Path(deployment["services_root"])
    marker = services_root / "miter-services.json"
    if occupied and not marker.exists():
        raise InstallError(
            "Configured service ports are already occupied by non-installer state: " + ", ".join(occupied)
            + ". Preserve them with --reuse-local-services or change config/miter.json."
        )
    services_root.mkdir(parents=True, exist_ok=True)
    compose = services_root / "compose.yaml"
    operator = invoking_user(deployment["runtime_user"])
    operator_account = pwd.getpwnam(operator)
    if os.geteuid() == 0:
        os.chown(services_root, operator_account.pw_uid, operator_account.pw_gid)
        services_root.chmod(0o700)
    if not compose.exists():
        password = secrets.token_urlsafe(36)
        compose.write_text(render_compose(config, password), encoding="utf-8")
        compose.chmod(0o600)
        marker.write_text(json.dumps({
            "schema": "miter-services-installation-v1",
            "docker_project": deployment["docker_project"],
            "standing": "installer-owned-isolated-services",
        }, sort_keys=True) + "\n", encoding="utf-8")
        marker.chmod(0o600)
        if os.geteuid() == 0:
            os.chown(compose, operator_account.pw_uid, operator_account.pw_gid)
            os.chown(marker, operator_account.pw_uid, operator_account.pw_gid)
    docker = command_path("docker")
    run([docker, "compose", "--project-name", deployment["docker_project"],
         "--file", str(compose), "up", "--detach"], user=operator)
    deadline = time.monotonic() + 180
    while time.monotonic() < deadline:
        if endpoint_available(mattermost) and endpoint_available(chroma):
            return "isolated-services-healthy"
        time.sleep(2)
    raise InstallError("Isolated services did not become healthy within 180 seconds")


def preflight_services(config: dict, *, reuse: bool) -> None:
    deployment = config["deployment"]
    mattermost = config["mattermost"]["origin"] + "/api/v4/system/ping"
    chroma = config["memory"]["chroma"]["origin"] + "/api/v2/heartbeat"
    occupied = [name for name, url in (("Mattermost", mattermost), ("Chroma", chroma)) if endpoint_available(url)]
    marker = pathlib.Path(deployment["services_root"]) / "miter-services.json"
    if reuse and len(occupied) != 2:
        raise InstallError("Existing-service migration requires healthy loopback Mattermost and Chroma")
    if not reuse and occupied and not marker.exists():
        raise InstallError(
            "Configured service ports are already occupied by non-installer state: " + ", ".join(occupied)
            + ". Preserve them with --reuse-local-services or change config/miter.json."
        )


def create_private_runtime_parent(deployment: dict, account: pwd.struct_passwd) -> None:
    runtime = pathlib.Path(deployment["runtime_root"])
    parent = runtime.parent
    parent.mkdir(parents=True, exist_ok=True)
    for path in (parent,):
        os.chown(path, account.pw_uid, account.pw_gid)
        path.chmod(0o700)


def runtime_marker_valid(runtime: pathlib.Path) -> bool:
    try:
        marker = json_document(runtime / "runtime.json")
    except InstallError:
        return False
    lkg = marker.get("lkg_sha256")
    return (
        marker.get("schema") == "miter-assistant-runtime-v1"
        and isinstance(lkg, str)
        and len(lkg) == 64
        and (runtime / "lkg.json").is_file()
    )


def incomplete_runtime_has_material_state(runtime: pathlib.Path) -> bool:
    for relative in DURABLE_RUNTIME_DIRECTORIES:
        path = runtime / relative
        if path.is_file() or (path.is_dir() and any(
                candidate.is_file() or candidate.is_symlink()
                for candidate in path.rglob("*")
        )):
            return True
    return any((runtime / name).exists() for name in (
        "runtime.json", "migration.json", "pid.json", "continuity-manifest.json",
    ))


def quarantine_incomplete_runtime(runtime: pathlib.Path) -> pathlib.Path | None:
    if not runtime.exists() or runtime_marker_valid(runtime):
        return None
    if not runtime.is_dir() or runtime.is_symlink():
        raise InstallError(f"Configured runtime target is not a safe directory: {runtime}")
    if incomplete_runtime_has_material_state(runtime):
        raise InstallError(
            "Configured runtime is incomplete but contains possible durable state; "
            f"refusing automatic recovery: {runtime}"
        )
    timestamp = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    target = runtime.with_name(f"{runtime.name}.incomplete-{timestamp}-{os.getpid()}")
    if target.exists():
        raise InstallError(f"Incomplete-runtime quarantine already exists: {target}")
    runtime.rename(target)
    return target


def child_failure(result: subprocess.CompletedProcess[str], context: str,
                  quarantine: pathlib.Path | None = None) -> InstallError:
    def bounded(value: str | None) -> str:
        text = (value or "").strip()
        return text[-4000:] if text else "<empty>"

    suffix = f"; incomplete runtime preserved at {quarantine}" if quarantine else ""
    return InstallError(
        f"{context} exited {result.returncode}{suffix}; "
        f"stdout={bounded(result.stdout)!r}; stderr={bounded(result.stderr)!r}"
    )


def json_document(path: pathlib.Path) -> dict:
    try:
        document = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise InstallError(f"Cannot read required JSON {path}: {exc}") from exc
    if not isinstance(document, dict):
        raise InstallError(f"Expected a JSON object at {path}")
    return document


def ensure_runtime_stopped(source: pathlib.Path) -> None:
    if not source.is_absolute() or source == pathlib.Path("/"):
        raise InstallError("Migration source must be an explicit absolute runtime path")
    runtime = json_document(source / "runtime.json")
    if runtime.get("schema") != "miter-assistant-runtime-v1":
        raise InstallError("Migration source is not a Miter runtime")
    pid_path = source / "pid.json"
    if pid_path.exists():
        pid = json_document(pid_path).get("pid")
        if isinstance(pid, int) and pid > 1:
            try:
                os.kill(pid, 0)
            except ProcessLookupError:
                pass
            except PermissionError:
                raise InstallError("Cannot establish whether the migration source process is stopped")
            else:
                raise InstallError(f"Migration source is still running as PID {pid}; stop it at a safe cycle boundary first")
    leased = source / "leased"
    if leased.is_dir() and any(leased.iterdir()):
        raise InstallError("Migration source contains an in-flight leased input")


def verify_runtime_checkpoint(source: pathlib.Path) -> str:
    active_path = source / "checkpoints" / "active.json"
    active = json_document(active_path)
    if active.get("schema") != "miter-assistant-checkpoint-v3":
        raise InstallError("Migration source has no supported active checkpoint")
    for path_key, hash_key in (
        ("checkpoint_object", "checkpoint_object_sha256"),
        ("continuity_manifest", "continuity_manifest_sha256"),
    ):
        relative = active.get(path_key)
        expected = active.get(hash_key)
        if not isinstance(relative, str) or relative.startswith("/") or ".." in pathlib.PurePosixPath(relative).parts:
            raise InstallError(f"Unsafe checkpoint reference: {relative}")
        path = source / relative
        if not path.is_file() or path.is_symlink() or sha256_file(path) != expected:
            raise InstallError(f"Checkpoint identity mismatch for {relative}")
    return sha256_file(active_path)


def secure_owned_tree(root: pathlib.Path, account: pwd.struct_passwd) -> None:
    for path in [root, *root.rglob("*")]:
        if path.is_symlink():
            raise InstallError(f"Private runtime contains an unsupported symlink: {path}")
        if path.is_dir():
            path.chmod(0o700)
        elif path.is_file():
            path.chmod(0o700 if path.name == "libmiter_store_posix.dylib" else 0o600)
        os.chown(path, account.pw_uid, account.pw_gid)


def copy_durable_directory(source: pathlib.Path, target: pathlib.Path) -> None:
    if not source.exists():
        return
    for path in [source, *source.rglob("*")]:
        if path.is_symlink():
            raise InstallError(f"Migration source contains an unsupported symlink: {path}")
    for path in sorted(source.rglob("*")):
        relative = path.relative_to(source)
        destination = target / relative
        if path.is_dir():
            destination.mkdir(parents=True, exist_ok=True)
        elif path.is_file():
            destination.parent.mkdir(parents=True, exist_ok=True)
            if destination.exists() and destination.read_bytes() != path.read_bytes():
                raise InstallError(f"Fresh runtime unexpectedly contains mutable state at {destination}")
            if not destination.exists():
                shutil.copy2(path, destination)


def backup_runtime(source: pathlib.Path, deployment: dict) -> pathlib.Path:
    runtime = json_document(source / "runtime.json")
    runtime_id = runtime.get("runtime_id")
    if not isinstance(runtime_id, str) or not runtime_id:
        raise InstallError("Migration source has no runtime identity")
    backup_root = pathlib.Path(deployment["services_root"]).parent / "migration-backups"
    backup_root.mkdir(parents=True, exist_ok=True)
    timestamp = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    target = backup_root / f"{runtime_id}-{timestamp}"
    if target.exists():
        raise InstallError(f"Migration backup already exists: {target}")
    shutil.copytree(source, target, symlinks=False)
    marker = target / "MIGRATION_BACKUP.json"
    marker.write_text(json.dumps({
        "schema": "miter-runtime-migration-backup-v1",
        "runtime_id": runtime_id,
        "source": str(source),
        "checkpoint_active_sha256": verify_runtime_checkpoint(source),
        "created_at_epoch": time.time(),
        "standing": "immutable-pre-migration-backup",
    }, sort_keys=True) + "\n", encoding="utf-8")
    make_read_only_tree(target)
    return target


def migrate_runtime_state(source: pathlib.Path, target: pathlib.Path,
                          deployment: dict, account: pwd.struct_passwd) -> dict:
    ensure_runtime_stopped(source)
    source_checkpoint_hash = verify_runtime_checkpoint(source)
    marker_path = target / "migration.json"
    if marker_path.exists():
        marker = json_document(marker_path)
        if marker.get("source_checkpoint_active_sha256") != source_checkpoint_hash:
            raise InstallError("Existing migration marker names a different source checkpoint")
        return marker
    backup = backup_runtime(source, deployment)
    for relative in DURABLE_RUNTIME_DIRECTORIES:
        copy_durable_directory(source / relative, target / relative)
    for relative in DURABLE_RUNTIME_FILES:
        source_file = source / relative
        if source_file.is_file() and not source_file.is_symlink():
            shutil.copy2(source_file, target / relative)
    source_runtime = json_document(source / "runtime.json")
    target_runtime = json_document(target / "runtime.json")
    migrated_runtime = {
        "schema": "miter-assistant-runtime-v1",
        "runtime_id": source_runtime["runtime_id"],
        "lkg_sha256": target_runtime["lkg_sha256"],
        "external_effects": source_runtime.get("external_effects", "none"),
        "network_access": "dedicated-user-open-growth-environment",
    }
    if isinstance(source_runtime.get("evaluation_grant_id"), str):
        migrated_runtime["evaluation_grant_id"] = source_runtime["evaluation_grant_id"]
    (target / "runtime.json").write_text(json.dumps(migrated_runtime, sort_keys=True) + "\n", encoding="utf-8")
    evaluation = json_document(target / "evaluation-grants.json")
    if evaluation.get("standing") == "active-explicit-grants":
        mattermost_path = target / "mattermost.json"
        mattermost = json_document(mattermost_path)
        mattermost["outbound"]["enabled"] = True
        mattermost_path.write_text(json.dumps(mattermost, sort_keys=True) + "\n", encoding="utf-8")
    marker = {
        "schema": "miter-runtime-migration-v1",
        "source_runtime": str(source),
        "source_runtime_id": source_runtime["runtime_id"],
        "source_checkpoint_active_sha256": source_checkpoint_hash,
        "backup": str(backup),
        "standing": "durable-state-copied-awaiting-cold-restore",
    }
    marker_path.write_text(json.dumps(marker, sort_keys=True) + "\n", encoding="utf-8")
    secure_owned_tree(target, account)
    return marker


def suspend_surface_poll(runtime: pathlib.Path, account: pwd.struct_passwd) -> bytes | None:
    path = runtime / "surface" / "mattermost-poll.json"
    prior = path.read_bytes() if path.exists() else None
    held = {
        "schema": "miter-mattermost-poll-v1",
        "observed_at_epoch": time.time() + 3600,
        "standing": "migration-cold-restore-poll-held",
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(held, sort_keys=True) + "\n", encoding="utf-8")
    os.chown(path, account.pw_uid, account.pw_gid)
    path.chmod(0o600)
    return prior


def restore_surface_poll(runtime: pathlib.Path, prior: bytes | None,
                         account: pwd.struct_passwd) -> None:
    path = runtime / "surface" / "mattermost-poll.json"
    if prior is None:
        path.unlink(missing_ok=True)
        return
    path.write_bytes(prior)
    os.chown(path, account.pw_uid, account.pw_gid)
    path.chmod(0o600)


def mark_migration_restored(runtime: pathlib.Path, marker: dict,
                            account: pwd.struct_passwd) -> dict:
    expected = marker["source_checkpoint_active_sha256"]
    actual = sha256_file(runtime / "checkpoints" / "active.json")
    if actual != expected:
        raise InstallError("Cold restore changed the migration checkpoint before contact resumed")
    restored = dict(marker)
    restored["standing"] = "cold-restore-verified-no-replay"
    restored["restored_at_epoch"] = time.time()
    path = runtime / "migration.json"
    path.write_text(json.dumps(restored, sort_keys=True) + "\n", encoding="utf-8")
    os.chown(path, account.pw_uid, account.pw_gid)
    path.chmod(0o600)
    return restored


def miter_environment(petta: pathlib.Path) -> dict[str, str]:
    environment = os.environ.copy()
    environment["MITER_PETTA_MAIN"] = str(petta / "src" / "main.pl")
    environment["MITER_SWIPL_LD"] = command_path("swipl-ld")
    return environment


def miter_command(application: pathlib.Path, deployment: dict, petta: pathlib.Path,
                  command: str, *, check: bool = True) -> subprocess.CompletedProcess[str]:
    private_working_directory = pathlib.Path(deployment["runtime_root"]).parent
    return run([
        "/usr/bin/env",
        f"MITER_PETTA_MAIN={petta / 'src' / 'main.pl'}",
        f"MITER_SWIPL_LD={command_path('swipl-ld')}",
        str(application / "bin" / "miter"), command,
        "--runtime-root", deployment["runtime_root"],
    ], check=check, user=deployment["runtime_user"],
       cwd=private_working_directory)


def store_secret(runtime: pathlib.Path, relative: str, value: str,
                 account: pwd.struct_passwd) -> None:
    if len(value.strip()) < 16 or "\n" in value or "\r" in value:
        raise InstallError(f"Credential {relative} is empty, short, or multiline")
    path = (runtime / relative).resolve()
    if runtime.resolve() not in path.parents:
        raise InstallError("Credential destination escaped the private runtime")
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        os.write(descriptor, value.strip().encode("utf-8") + b"\n")
        os.fsync(descriptor)
    finally:
        os.close(descriptor)
    os.chown(path, account.pw_uid, account.pw_gid)
    path.chmod(0o600)


def credential_references(config: dict) -> list[tuple[str, str]]:
    references: list[tuple[str, str]] = []
    mattermost = config["mattermost"]["credential_reference"]
    references.append(("Mattermost bot token", mattermost["relative_path"]))
    for profile in config["models"]["resources"]:
        reference = profile.get("credential_reference")
        if reference:
            references.append((f"{profile['id']} API key", reference["relative_path"]))
    return references


def keychain_import(config: dict, relative: str) -> str | None:
    for source in config["deployment"].get("credential_imports", []):
        if source.get("relative_path") != relative:
            continue
        if source.get("source") != "macos-keychain":
            raise InstallError(f"Unsupported credential import for {relative}")
        result = run([
            "/usr/bin/security", "find-generic-password", "-w",
            "-a", source["account"], "-s", source["service"],
        ], check=False, user=source["account"])
        if result.returncode == 0 and len(result.stdout.strip()) >= 16:
            return result.stdout.strip()
    return None


def provision_credentials(config: dict, account: pwd.struct_passwd,
                          import_keychain: bool) -> list[str]:
    runtime = pathlib.Path(config["deployment"]["runtime_root"])
    missing: list[str] = []
    for label, relative in credential_references(config):
        path = runtime / relative
        if path.exists():
            if stat.S_IMODE(path.stat().st_mode) != 0o600 or path.stat().st_uid != account.pw_uid:
                raise InstallError(f"Existing credential has unsafe ownership or mode: {path}")
            continue
        value = keychain_import(config, relative) if import_keychain else None
        if value:
            store_secret(runtime, relative, value, account)
            continue
        if not sys.stdin.isatty():
            missing.append(label)
            continue
        value = getpass.getpass(f"Paste {label} (leave blank to finish later): ")
        if not value:
            missing.append(label)
            continue
        store_secret(runtime, relative, value, account)
    return missing


def plist_xml(application: pathlib.Path, deployment: dict, petta: pathlib.Path) -> str:
    runtime = deployment["runtime_root"]
    swipl = command_path("swipl")
    operator = application / "effect_membranes" / "assistant_operator.pl"
    escaped = lambda text: (str(text).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))
    arguments = [swipl, "-q", "-f", "none", "-s", str(operator), "--",
                 "run-supervised", "--runtime-root", runtime]
    argument_xml = "\n".join(f"      <string>{escaped(value)}</string>" for value in arguments)
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>{LAUNCHD_LABEL}</string>
  <key>UserName</key><string>{deployment['runtime_user']}</string>
  <key>GroupName</key><string>staff</string>
  <key>ProgramArguments</key><array>
{argument_xml}
  </array>
  <key>EnvironmentVariables</key><dict>
    <key>HOME</key><string>/Users/{deployment['runtime_user']}</string>
    <key>MITER_PETTA_MAIN</key><string>{escaped(petta / 'src' / 'main.pl')}</string>
    <key>MITER_SWIPL_LD</key><string>{escaped(command_path('swipl-ld'))}</string>
  </dict>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
  <key>ProcessType</key><string>Interactive</string>
</dict></plist>
'''


def install_launchd(application: pathlib.Path, deployment: dict, petta: pathlib.Path) -> None:
    if os.geteuid() != 0:
        raise InstallError("Run install with sudo so it can register the system service")
    if LAUNCHD_PATH.exists():
        result = run(["/bin/launchctl", "print", f"system/{LAUNCHD_LABEL}"], check=False)
        if result.returncode == 0:
            run(["/bin/launchctl", "bootout", f"system/{LAUNCHD_LABEL}"], check=False)
    LAUNCHD_PATH.write_text(plist_xml(application, deployment, petta), encoding="utf-8")
    os.chown(LAUNCHD_PATH, 0, 0)
    LAUNCHD_PATH.chmod(0o644)
    run(["/usr/bin/plutil", "-lint", str(LAUNCHD_PATH)])
    run(["/bin/launchctl", "bootstrap", "system", str(LAUNCHD_PATH)])


def install_operator_wrapper(application: pathlib.Path, deployment: dict, petta: pathlib.Path) -> None:
    if os.geteuid() != 0:
        raise InstallError("Run install with sudo so it can install the operator command")
    runtime = deployment["runtime_root"]
    user = deployment["runtime_user"]
    text = f'''#!/bin/sh
set -eu
command=${{1:-}}
if [ "$command" = start ]; then
  exec /usr/bin/sudo /bin/launchctl kickstart -k system/{LAUNCHD_LABEL}
fi
exec /usr/bin/sudo -u {user} -H /usr/bin/env \\
  MITER_PETTA_MAIN={shell_quote(str(petta / 'src' / 'main.pl'))} \\
  MITER_SWIPL_LD={shell_quote(command_path('swipl-ld'))} \\
  {shell_quote(str(application / 'bin' / 'miter'))} "$@" \\
  --runtime-root {shell_quote(runtime)}
'''
    OPERATOR_PATH.parent.mkdir(parents=True, exist_ok=True)
    OPERATOR_PATH.write_text(text, encoding="utf-8")
    os.chown(OPERATOR_PATH, 0, 0)
    OPERATOR_PATH.chmod(0o755)


def shell_quote(value: str) -> str:
    return "'" + value.replace("'", "'\\''") + "'"


def validate(config: dict, application: pathlib.Path | None = None,
             petta: pathlib.Path | None = None) -> dict:
    deployment = config["deployment"]
    account = runtime_account(deployment["runtime_user"])
    checks: dict[str, str] = {}
    checks["runtime_identity"] = "present-non-admin" if account else "missing"
    runtime = pathlib.Path(deployment["runtime_root"])
    try:
        runtime_ready = runtime.is_dir() and stat.S_IMODE(runtime.stat().st_mode) == 0o700
    except PermissionError:
        runtime_ready = False
    checks["runtime_root"] = "private-present" if runtime_ready else "missing-inaccessible-or-not-private"
    missing_credentials = []
    if account and runtime_ready:
        for label, relative in credential_references(config):
            path = runtime / relative
            if not path.is_file() or stat.S_IMODE(path.stat().st_mode) != 0o600 or path.stat().st_uid != account.pw_uid:
                missing_credentials.append(label)
    else:
        missing_credentials = [label for label, _ in credential_references(config)]
    checks["credentials"] = "private-present" if not missing_credentials else "missing:" + ",".join(missing_credentials)
    checks["chroma"] = "healthy" if endpoint_available(config["memory"]["chroma"]["origin"] + "/api/v2/heartbeat") else "unavailable"
    checks["mattermost"] = "healthy" if endpoint_available(config["mattermost"]["origin"] + "/api/v4/system/ping") else "unavailable"
    if application and petta and account and runtime_ready:
        result = miter_command(application, deployment, petta, "status", check=False)
        try:
            status = json.loads(result.stdout or "{}")
            checks["miter"] = f"{status.get('status','unknown')};lkg={status.get('lkg','unknown')}"
        except json.JSONDecodeError:
            checks["miter"] = "operator-invalid"
    checks["launchd"] = "registered" if run(["/bin/launchctl", "print", f"system/{LAUNCHD_LABEL}"], check=False).returncode == 0 else "not-registered"
    complete = all(value in {"present-non-admin", "private-present", "healthy", "registered"} or value.startswith(("running;lkg=verified", "stopped;lkg=verified")) for value in checks.values())
    return {"schema": "miter-installation-validation-v1", "complete": complete, "checks": checks}


def print_commands() -> None:
    print("Ordinary Miter operator commands:")
    print("  miter start")
    print("  miter status")
    print("  miter stop")
    print("  miter panic")
    print("  miter model-selection")


def plan(config: dict) -> dict:
    deployment = config["deployment"]
    account = runtime_account(deployment["runtime_user"])
    mattermost = endpoint_available(config["mattermost"]["origin"] + "/api/v4/system/ping")
    chroma = endpoint_available(config["memory"]["chroma"]["origin"] + "/api/v2/heartbeat")
    return {
        "schema": "miter-installation-plan-v1",
        "source": str(SOURCE_ROOT),
        "runtime_user": deployment["runtime_user"],
        "runtime_user_standing": "present" if account else "will-create",
        "runtime_root": deployment["runtime_root"],
        "application_root": deployment["application_root"],
        "dependency_root": deployment["dependency_root"],
        "services_root": deployment["services_root"],
        "configured_ports": {
            "mattermost": "occupied" if mattermost else "available",
            "chroma": "occupied" if chroma else "available",
        },
        "default_service_action": "refuse-unowned-collision;create-isolated-when-available",
        "migration_alternative": "--reuse-local-services preserves the explicitly selected healthy local services",
        "destructive_actions": [],
    }


def install(config: dict, reuse_services: bool, import_keychain: bool,
            migrate_runtime: str | None) -> dict:
    if os.geteuid() != 0:
        raise InstallError("Run this command with sudo; plan and validate are read-only")
    require_supported_host()
    deployment = config["deployment"]
    identity = source_identity()
    preflight_services(config, reuse=reuse_services)
    account = ensure_runtime_account(deployment["runtime_user"])
    petta = install_petta(deployment)
    application = install_application(deployment, identity)
    service_standing = install_services(config, reuse=reuse_services)
    create_private_runtime_parent(deployment, account)
    runtime = pathlib.Path(deployment["runtime_root"])
    recovered_incomplete_runtime = quarantine_incomplete_runtime(runtime)
    if not runtime.exists():
        result = miter_command(application, deployment, petta, "install",
                               check=False)
        if result.returncode != 0:
            quarantine = quarantine_incomplete_runtime(runtime)
            raise child_failure(result, "Dedicated-user runtime bootstrap",
                                quarantine)
        try:
            response = json.loads(result.stdout)
        except json.JSONDecodeError as exc:
            quarantine = quarantine_incomplete_runtime(runtime)
            raise child_failure(result, "Dedicated-user runtime bootstrap returned invalid JSON",
                                quarantine) from exc
        if response.get("status") != "installed":
            quarantine = quarantine_incomplete_runtime(runtime)
            raise InstallError(
                f"Runtime installation failed: {response.get('status')}; "
                f"incomplete runtime preserved at {quarantine}"
            )
    migration = None
    migration_pending_restore = False
    if migrate_runtime:
        source_runtime = pathlib.Path(migrate_runtime).resolve()
        if source_runtime == runtime.resolve():
            raise InstallError("Migration source and destination are identical")
        migration = migrate_runtime_state(source_runtime,runtime,deployment,account)
        migration_pending_restore = (
            migration.get("standing") ==
            "durable-state-copied-awaiting-cold-restore"
        )
    missing = provision_credentials(config, account, import_keychain)
    if missing:
        return {
            "schema": "miter-installation-result-v1",
            "status": "awaiting-private-credentials",
            "application": str(application),
            "petta": str(petta),
            "runtime": str(runtime),
            "services": service_standing,
            "recovered_incomplete_runtime": (
                str(recovered_incomplete_runtime)
                if recovered_incomplete_runtime else None
            ),
            "migration": migration,
            "missing": missing,
            "next": "Run the same install command interactively to finish without replacing existing state.",
        }
    prior_poll = (
        suspend_surface_poll(runtime,account)
        if migration_pending_restore else None
    )
    try:
        start = miter_command(application, deployment, petta, "start", check=False)
        if start.returncode != 0:
            raise child_failure(start,
              "Miter could not complete its pre-registration start validation")
        try:
            start_reply = json.loads(start.stdout)
        except json.JSONDecodeError as exc:
            raise InstallError("Miter returned an invalid start validation result") from exc
        if start_reply.get("mattermost_preflight") != "ready":
            miter_command(application, deployment, petta, "stop", check=False)
            raise InstallError("Mattermost bot/group identity could not be validated; no service was registered")
        stopped = miter_command(application, deployment, petta, "stop", check=False)
        if stopped.returncode != 0:
            raise child_failure(stopped,
              "Miter did not reach a clean post-restore stop boundary")
        if migration_pending_restore:
            migration = mark_migration_restored(runtime,migration,account)
    finally:
        if migration_pending_restore:
            restore_surface_poll(runtime,prior_poll,account)
    install_launchd(application, deployment, petta)
    install_operator_wrapper(application, deployment, petta)
    report = validate(config, application, petta)
    report.update({
        "status": "installed-and-started" if report["complete"] else "installed-validation-held",
        "application": str(application), "petta": str(petta),
        "runtime": str(runtime), "services": service_standing,
        "recovered_incomplete_runtime": (
            str(recovered_incomplete_runtime)
            if recovered_incomplete_runtime else None
        ),
        "migration": migration,
    })
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description="Install the Miter PeTTa/MeTTa assistant")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("plan", help="Inspect the exact non-destructive installation plan")
    install_parser = subparsers.add_parser("install", help="Install and validate Miter")
    install_parser.add_argument("--reuse-local-services", action="store_true",
                                help="Explicitly preserve and reuse healthy configured Mattermost and Chroma services")
    install_parser.add_argument("--import-keychain-credentials", action="store_true",
                                help="Import the exact named Keychain sources into the private runtime without printing them")
    install_parser.add_argument("--migrate-runtime", metavar="ABSOLUTE_PATH",
                                help="Preserve one stopped Miter runtime's exact identity, continuity, developmental state, and receipts")
    subparsers.add_parser("validate", help="Read-only installation validation")
    subparsers.add_parser("commands", help="Print ordinary operator commands")
    args = parser.parse_args()
    try:
        config = load_config()
        if args.command == "plan":
            result = plan(config)
        elif args.command == "install":
            result = install(config, args.reuse_local_services,
                             args.import_keychain_credentials,
                             args.migrate_runtime)
        elif args.command == "validate":
            result = validate(config)
        else:
            print_commands()
            return 0
        print(json.dumps(result, indent=2, sort_keys=True))
        if args.command == "install" and result.get("status") == "installed-and-started":
            print_commands()
        return 0 if args.command != "validate" or result.get("complete") else 1
    except InstallError as exc:
        print(json.dumps({"schema": "miter-installation-error-v1", "error": str(exc)}, sort_keys=True), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
