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
    "private-assets/NRC-VAD-Lexicon-v2.1.txt",
)
INPUT_LIFECYCLE_DIRECTORIES = ("inbox", "leased", "consumed", "rejected")
RELEASE_STATE_SCHEMA = "miter-application-release-state-v1"


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
    root_text = deployment.get("install_root")
    if not isinstance(root_text, str):
        raise InstallError("The deployment must name one absolute install_root")
    install_root = pathlib.Path(root_text)
    expected_root = pathlib.Path("/Users") / deployment["runtime_user"] / "Miter"
    if not install_root.is_absolute() or install_root != expected_root:
        raise InstallError(
            f"Miter must remain in its dedicated account root: {expected_root}"
        )
    forbidden_roots = {
        "runtime_root", "application_root", "dependency_root", "services_root",
    }.intersection(deployment)
    if forbidden_roots:
        raise InstallError(
            "Deployment subpaths are derived from install_root and may not be configured separately: "
            + ", ".join(sorted(forbidden_roots))
        )
    deployment.update({
        "application_root": str(install_root / "application"),
        "dependency_root": str(install_root / "dependencies"),
        "runtime_root": str(install_root / "private" / "runtime"),
        "services_root": str(install_root / "services"),
        "backup_root": str(install_root / "private-backups"),
        "broker_root": str(install_root / "broker"),
        "operator_path": str(install_root / "bin" / "miter"),
    })
    return document


def command_path(name: str) -> str:
    found = shutil.which(name)
    if not found:
        raise InstallError(f"Required host command is unavailable: {name}")
    return found


def validate_metta_source_balance() -> None:
    """Reject partial forms and malformed native let* binding syntax.

    PeTTa currently does not propagate every nested ``import!`` parse failure
    to the outer bootstrap process.  This packaging-only scan therefore checks
    lexical boundaries and let* arity before an application identity is admitted.
    It assigns no runtime meaning and does not evaluate cognition.
    """
    source_roots = (SOURCE_ROOT / "constitution", SOURCE_ROOT / "src")
    paths = sorted(
        path
        for root in source_roots
        for path in root.rglob("*.metta")
        if path.is_file()
    )
    for path in paths:
        openings: list[tuple[int, int]] = []
        forms: list[tuple[str | None, int]] = []

        def note_child(symbol: str | None = None) -> None:
            if forms:
                head, count = forms[-1]
                forms[-1] = (symbol if count == 0 else head, count + 1)

        in_string = False
        escaped = False
        line_number = 1
        column_number = 0
        try:
            source = path.read_text(encoding="utf-8")
        except OSError as exc:
            raise InstallError(f"Cannot validate MeTTa source {path}: {exc}") from exc
        index = 0
        while index < len(source):
            character = source[index]
            column_number += 1
            if character == "\n":
                line_number += 1
                column_number = 0
                escaped = False
                index += 1
                continue
            if in_string:
                if escaped:
                    escaped = False
                elif character == "\\":
                    escaped = True
                elif character == '"':
                    in_string = False
                index += 1
                continue
            if character == ";":
                newline = source.find("\n", index)
                if newline < 0:
                    index = len(source)
                else:
                    index = newline
                continue
            if character == '"':
                note_child()
                in_string = True
            elif character == "(":
                note_child()
                openings.append((line_number, column_number))
                forms.append((None, 0))
            elif character == ")":
                if not openings:
                    relative = path.relative_to(SOURCE_ROOT)
                    raise InstallError(
                        f"Unmatched ')' in {relative}:{line_number}:{column_number}"
                    )
                opening_line, opening_column = openings.pop()
                head, count = forms.pop()
                if head == "let*" and count != 3:
                    relative = path.relative_to(SOURCE_ROOT)
                    raise InstallError(
                        f"Malformed let* in {relative}:{opening_line}:{opening_column}: "
                        f"expected bindings and one body, found {count - 1} arguments"
                    )
            elif not character.isspace():
                end = index + 1
                while end < len(source) and not source[end].isspace() and source[end] not in '();"':
                    end += 1
                note_child(source[index:end])
                column_number += end - index - 1
                index = end
                continue
            index += 1
        relative = path.relative_to(SOURCE_ROOT)
        if in_string:
            raise InstallError(f"Unterminated string in {relative}")
        if openings:
            opening_line, opening_column = openings[-1]
            raise InstallError(
                f"Unclosed MeTTa form in {relative}:{opening_line}:{opening_column}"
            )


def source_identity() -> str:
    validate_metta_source_balance()
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


def ensure_install_root(deployment: dict, account: pwd.struct_passwd) -> pathlib.Path:
    root = pathlib.Path(deployment["install_root"])
    account_home = root.parent
    if account_home.is_symlink() or not account_home.is_dir():
        raise InstallError(f"Dedicated account home is not a safe directory: {account_home}")
    if account_home.stat().st_uid != account.pw_uid:
        raise InstallError(f"Dedicated account home is not owned by {account.pw_name}")
    if root.is_symlink() or (root.exists() and not root.is_dir()):
        raise InstallError(f"Miter install root is not a safe directory: {root}")
    if not root.exists():
        root.mkdir(mode=0o755)
        os.chown(root, 0, 0)
    if root.stat().st_uid != 0:
        raise InstallError("The Miter install root must remain root-owned")
    root.chmod(0o755)
    marker_path = root / "installation-root.json"
    marker = {
        "schema": "miter-installation-root-v1",
        "install_root": str(root),
        "runtime_user": deployment["runtime_user"],
        "standing": "single-miter-owned-root",
    }
    allowed = {
        "installation-root.json", "application", "dependencies", "private",
        "private-backups", "services", "broker", "bin",
    }
    unexpected = sorted(path.name for path in root.iterdir()
                        if path.name not in allowed)
    if unexpected:
        raise InstallError(
            "Miter install root contains non-distribution entries: "
            + ", ".join(unexpected)
        )
    if marker_path.exists():
        if (not marker_path.is_file() or marker_path.is_symlink()
                or marker_path.stat().st_uid != 0
                or stat.S_IMODE(marker_path.stat().st_mode) != 0o644
                or json_document(marker_path) != marker):
            raise InstallError("Miter install root marker is missing or invalid")
    else:
        if any(root.iterdir()):
            raise InstallError(
                "Existing Miter install root has no installation-root marker"
            )
        marker_path.write_text(json.dumps(marker, sort_keys=True) + "\n",
                               encoding="utf-8")
        os.chown(marker_path, 0, 0)
        marker_path.chmod(0o644)
    return root


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


def make_private_read_only_tree(root: pathlib.Path) -> None:
    """Make a continuity backup immutable to ordinary users and private to root."""
    for path in [root, *root.rglob("*")]:
        if path.is_symlink():
            raise InstallError(f"Private backup contains an unsupported symlink: {path}")
        if path.is_dir():
            path.chmod(0o700)
        elif path.is_file():
            path.chmod(0o400)
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
         "--file", str(compose), "up", "--detach"], user=operator,
        cwd="/private/tmp")
    deadline = time.monotonic() + 180
    while time.monotonic() < deadline:
        if endpoint_available(mattermost) and endpoint_available(chroma):
            return "isolated-services-healthy"
        time.sleep(2)
    raise InstallError("Isolated services did not become healthy within 180 seconds")


def ensure_workshop_image(config: dict) -> str:
    """Acquire the exact non-cognitive candidate runner during installation."""
    deployment = config["deployment"]
    image = deployment["images"].get("workshop")
    if image != config["growth_environment"]["workshop"].get("image"):
        raise InstallError("Workshop image identity differs across configuration surfaces")
    docker = command_path("docker")
    operator = invoking_user(deployment["runtime_user"])
    inspect = run([docker, "image", "inspect", image], check=False,
                  user=operator, cwd="/private/tmp")
    if inspect.returncode != 0:
        run([docker, "pull", image], user=operator, cwd="/private/tmp")
        inspect = run([docker, "image", "inspect", image], check=False,
                      user=operator, cwd="/private/tmp")
    if inspect.returncode != 0:
        raise InstallError("Exact workshop runner image is unavailable after acquisition")
    return "exact-digest-present-to-operator-broker"


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
    if any((runtime / relative).exists() for relative in DURABLE_RUNTIME_FILES):
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


def durable_leased_input_manifest(runtime: pathlib.Path) -> list[dict]:
    """Identify restart-owned input carriers without interpreting their payload."""
    leased = runtime / "leased"
    if not leased.exists():
        return []
    if leased.is_symlink() or not leased.is_dir():
        raise InstallError("Runtime leased-input path is not a plain directory")
    manifest = []
    for path in sorted(leased.iterdir(), key=lambda candidate: candidate.name):
        if path.is_symlink() or not path.is_file() or path.suffix != ".json":
            raise InstallError(f"Runtime contains an unsafe leased-input carrier: {path}")
        document = json_document(path)
        schema = document.get("schema")
        input_id = document.get("input_id")
        if (schema not in {
                "miter-assistant-input-v1",
                "miter-assistant-input-v2",
                "miter-assistant-input-v3",
        } or not isinstance(input_id, str) or not input_id
                or path.name != f"{input_id}.json"):
            raise InstallError(f"Runtime contains an invalid leased-input carrier: {path}")
        manifest.append({
            "name": path.name,
            "sha256": sha256_file(path),
            "bytes": path.stat().st_size,
        })
    return manifest


def verify_carried_inputs_present(runtime: pathlib.Path,
                                  expected: list[dict]) -> list[dict]:
    """Prove each transition-carried input still has one exact lifecycle owner."""
    standings = []
    for entry in expected:
        if (not isinstance(entry, dict)
                or not isinstance(entry.get("name"), str)
                or not isinstance(entry.get("sha256"), str)
                or not isinstance(entry.get("bytes"), int)):
            raise InstallError("Release-transition leased-input manifest is malformed")
        matches = []
        for directory in INPUT_LIFECYCLE_DIRECTORIES:
            path = runtime / directory / entry["name"]
            if not path.exists():
                continue
            if (path.is_symlink() or not path.is_file()
                    or path.stat().st_size != entry["bytes"]
                    or sha256_file(path) != entry["sha256"]):
                raise InstallError(
                    f"Transition-carried input changed in {directory}: {entry['name']}"
                )
            matches.append(directory)
        if len(matches) != 1 or matches[0] not in {"leased", "consumed"}:
            raise InstallError(
                f"Transition-carried input has no unique live owner: {entry['name']}"
            )
        standings.append({"name": entry["name"], "standing": matches[0]})
    return standings


def ensure_runtime_stopped(source: pathlib.Path, *,
                           allow_durable_leases: bool = False) -> list[dict]:
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
    leased_manifest = durable_leased_input_manifest(source)
    if leased_manifest and not allow_durable_leases:
        raise InstallError("Migration source contains an in-flight leased input")
    return leased_manifest


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


def runtime_lkg_matches_application(runtime: pathlib.Path,
                                    application: pathlib.Path) -> bool:
    """Compare the stopped runtime snapshot with the selected application release."""
    try:
        runtime_marker = json_document(runtime / "runtime.json")
        lkg_path = runtime / "lkg.json"
        lkg = json_document(runtime / "lkg.json")
        files = lkg.get("files")
        if (lkg.get("schema") != "miter-assistant-lkg-v3"
                or not isinstance(files, list)
                or runtime_marker.get("lkg_sha256") != sha256_file(lkg_path)):
            return False
        for entry in files:
            if not isinstance(entry, dict):
                return False
            relative = entry.get("path")
            expected = entry.get("sha256")
            if (not isinstance(relative, str) or not isinstance(expected, str)
                    or relative.startswith("/")
                    or ".." in pathlib.PurePosixPath(relative).parts):
                return False
            source = application / relative
            if (not source.is_file() or source.is_symlink()
                    or sha256_file(source) != expected):
                return False
        return True
    except (InstallError, OSError, PermissionError):
        return False


def release_identity(application: pathlib.Path) -> str:
    identity = application.name
    if (len(identity) != 40
            or any(character not in "0123456789abcdef" for character in identity)):
        raise InstallError(f"Invalid installed application release identity: {application}")
    return identity


def active_application(deployment: dict, runtime: pathlib.Path) -> pathlib.Path:
    """Resolve the recorded release and verify it against the runtime's exact LKG.

    Distinct immutable releases can intentionally have identical runtime LKG
    bytes when a commit changes only finite installer or documentation
    machinery.  Once a release-state marker exists, exact recorded identity is
    therefore the selector and LKG equality is its integrity check.  A unique
    content search remains only for installations predating that marker.
    """
    releases = pathlib.Path(deployment["application_root"]) / "releases"
    if not releases.is_dir() or releases.is_symlink():
        raise InstallError("The installed application release root is missing or unsafe")

    state = read_release_state(deployment)
    if state is not None:
        recorded = releases / state["active_release"]
        release_identity(recorded)
        if not runtime_lkg_matches_application(runtime, recorded):
            raise InstallError(
                "The recorded active application release does not match the live runtime LKG"
            )
        return recorded

    matches = [
        path for path in sorted(releases.iterdir())
        if path.is_dir() and not path.is_symlink()
        and runtime_lkg_matches_application(runtime, path)
    ]
    if len(matches) != 1:
        raise InstallError(
            "The unrecorded live runtime LKG must match exactly one installed "
            "application release; "
            f"found {len(matches)}"
        )
    release_identity(matches[0])
    return matches[0]


def release_state_path(deployment: dict) -> pathlib.Path:
    return pathlib.Path(deployment["application_root"]) / "release-state.json"


def read_release_state(deployment: dict) -> dict | None:
    path = release_state_path(deployment)
    if not path.exists():
        return None
    if (not path.is_file() or path.is_symlink() or path.stat().st_uid != 0
            or stat.S_IMODE(path.stat().st_mode) != 0o644):
        raise InstallError("The application release-state marker is unsafe")
    state = json_document(path)
    if state.get("schema") != RELEASE_STATE_SCHEMA:
        raise InstallError("The application release-state marker has an unknown schema")
    releases = pathlib.Path(deployment["application_root"]) / "releases"
    for key in ("active_release", "previous_release"):
        identity = state.get(key)
        if identity is None and key == "previous_release":
            continue
        if not isinstance(identity, str):
            raise InstallError(f"The application release-state marker has no valid {key}")
        release_identity(releases / identity)
        if not (releases / identity).is_dir():
            raise InstallError(f"The application release-state marker names a missing {key}")
    return state


def write_release_state(deployment: dict, *, active: pathlib.Path,
                        previous: pathlib.Path | None, transition: str,
                        checkpoint_sha256: str, runtime_id: str,
                        backup: pathlib.Path) -> dict:
    document = {
        "schema": RELEASE_STATE_SCHEMA,
        "active_release": release_identity(active),
        "previous_release": release_identity(previous) if previous else None,
        "transition": transition,
        "runtime_id": runtime_id,
        "checkpoint_active_sha256": checkpoint_sha256,
        "continuity_backup": str(backup),
        "activated_at_epoch": time.time(),
        "standing": "active-after-cold-restore-no-replay",
    }
    path = release_state_path(deployment)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    temporary.write_text(json.dumps(document, sort_keys=True) + "\n",
                         encoding="utf-8")
    os.chown(temporary, 0, 0)
    temporary.chmod(0o644)
    os.replace(temporary, path)
    descriptor = os.open(path.parent, os.O_RDONLY)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)
    return document


def validated_migration_backup(source: pathlib.Path, backup: pathlib.Path,
                               deployment: dict) -> pathlib.Path:
    backup_root = pathlib.Path(deployment["backup_root"]).resolve()
    if (not backup.is_absolute() or backup.parent.resolve() != backup_root
            or backup.is_symlink() or not backup.is_dir()):
        raise InstallError("Prior migration backup is outside the exact private backup root")
    if backup.stat().st_uid != 0 or stat.S_IMODE(backup.stat().st_mode) != 0o700:
        raise InstallError("Prior migration backup has unsafe ownership or mode")
    marker_path = backup / "MIGRATION_BACKUP.json"
    marker = json_document(marker_path)
    source_runtime = json_document(source / "runtime.json")
    runtime_id = source_runtime.get("runtime_id")
    if not isinstance(runtime_id, str) or not runtime_id:
        raise InstallError("Migration source has no runtime identity")
    expected_checkpoint = verify_runtime_checkpoint(source)
    source_leases = durable_leased_input_manifest(source)
    expected_common = {
        "runtime_id": runtime_id,
        "source": str(source),
        "checkpoint_active_sha256": expected_checkpoint,
        "created_at_epoch": marker.get("created_at_epoch"),
        "standing": "immutable-pre-migration-backup",
    }
    actual_common = {key: marker.get(key) for key in expected_common}
    schema = marker.get("schema")
    leases_valid = (
        schema == "miter-runtime-migration-backup-v2"
        and marker.get("leased_inputs") == source_leases
    ) or (
        schema == "miter-runtime-migration-backup-v1"
        and not source_leases and "leased_inputs" not in marker
    )
    if (actual_common != expected_common or not leases_valid
            or not isinstance(marker.get("created_at_epoch"), (int, float))):
        raise InstallError("Prior migration backup marker does not match the exact source")
    if (marker_path.stat().st_uid != 0
            or stat.S_IMODE(marker_path.stat().st_mode) != 0o400
            or verify_runtime_checkpoint(backup) != expected_checkpoint
            or durable_leased_input_manifest(backup) != source_leases):
        raise InstallError("Prior migration backup failed identity or immutability checks")
    return backup


def prepare_failed_migration_retry(runtime: pathlib.Path, source: pathlib.Path,
                                   deployment: dict, application: pathlib.Path) -> dict | None:
    """Preserve one failed pre-contact target before rebuilding its current LKG."""
    if (not runtime_marker_valid(runtime)
            or runtime_lkg_matches_application(runtime, application)):
        return None
    marker_path = runtime / "migration.json"
    if not marker_path.is_file() or marker_path.is_symlink():
        raise InstallError(
            "Existing runtime differs from the selected release and is not a retryable migration"
        )
    marker = json_document(marker_path)
    source_checkpoint = verify_runtime_checkpoint(source)
    backup_value = marker.get("backup")
    if (marker.get("schema") != "miter-runtime-migration-v1"
            or marker.get("standing") != "durable-state-copied-awaiting-cold-restore"
            or marker.get("source_runtime") != str(source)
            or marker.get("source_checkpoint_active_sha256") != source_checkpoint
            or not isinstance(backup_value, str)
            or verify_runtime_checkpoint(runtime) != source_checkpoint):
        raise InstallError(
            "Existing runtime differs from the selected release outside the failed cold-restore boundary"
        )
    ensure_runtime_stopped(runtime)
    backup = validated_migration_backup(source, pathlib.Path(backup_value), deployment)
    timestamp = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    preserved = runtime.with_name(
        f"{runtime.name}.failed-cold-restore-{timestamp}-{os.getpid()}"
    )
    if preserved.exists():
        raise InstallError(f"Failed-runtime preservation target already exists: {preserved}")
    runtime.rename(preserved)
    return {
        "schema": "miter-failed-migration-retry-v1",
        "preserved": str(preserved),
        "backup": str(backup),
        "standing": "preserved-awaiting-verified-replacement",
    }


def remove_verified_failed_runtime(recovery: dict, runtime: pathlib.Path) -> dict:
    preserved = pathlib.Path(recovery["preserved"])
    expected_prefix = runtime.name + ".failed-cold-restore-"
    if (preserved.parent != runtime.parent or not preserved.name.startswith(expected_prefix)
            or preserved.is_symlink() or not preserved.is_dir()):
        raise InstallError("Refusing to remove an unexpected failed-runtime preservation path")
    shutil.rmtree(preserved)
    result = dict(recovery)
    result["standing"] = "removed-after-verified-replacement"
    return result


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


def require_plain_runtime_tree(source: pathlib.Path) -> None:
    if source.is_symlink() or not source.is_dir():
        raise InstallError(f"Migration source is not a plain runtime directory: {source}")
    for path in source.rglob("*"):
        if path.is_symlink():
            raise InstallError(f"Migration source contains an unsupported symlink: {path}")
        if not path.is_dir() and not path.is_file():
            raise InstallError(f"Migration source contains an unsupported file kind: {path}")


def backup_runtime(source: pathlib.Path, deployment: dict) -> pathlib.Path:
    require_plain_runtime_tree(source)
    runtime = json_document(source / "runtime.json")
    runtime_id = runtime.get("runtime_id")
    if not isinstance(runtime_id, str) or not runtime_id:
        raise InstallError("Migration source has no runtime identity")
    backup_root = pathlib.Path(deployment["backup_root"])
    backup_root.mkdir(parents=True, exist_ok=True)
    backup_root.chmod(0o700)
    if os.geteuid() == 0:
        os.chown(backup_root, 0, 0)
    timestamp = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    target = backup_root / f"{runtime_id}-{timestamp}"
    if target.exists():
        raise InstallError(f"Migration backup already exists: {target}")
    shutil.copytree(source, target, symlinks=False)
    marker = target / "MIGRATION_BACKUP.json"
    marker.write_text(json.dumps({
        "schema": "miter-runtime-migration-backup-v2",
        "runtime_id": runtime_id,
        "source": str(source),
        "checkpoint_active_sha256": verify_runtime_checkpoint(source),
        "leased_inputs": durable_leased_input_manifest(source),
        "created_at_epoch": time.time(),
        "standing": "immutable-pre-migration-backup",
    }, sort_keys=True) + "\n", encoding="utf-8")
    make_private_read_only_tree(target)
    return target


def migrate_runtime_state(source: pathlib.Path, target: pathlib.Path,
                          deployment: dict, account: pwd.struct_passwd,
                          prior_backup: pathlib.Path | None = None, *,
                          allow_durable_leases: bool = False) -> dict:
    source_leases = ensure_runtime_stopped(
        source, allow_durable_leases=allow_durable_leases
    )
    source_checkpoint_hash = verify_runtime_checkpoint(source)
    marker_path = target / "migration.json"
    if marker_path.exists():
        marker = json_document(marker_path)
        if marker.get("source_checkpoint_active_sha256") != source_checkpoint_hash:
            raise InstallError("Existing migration marker names a different source checkpoint")
        if (marker.get("source_leased_inputs", []) != source_leases
                or durable_leased_input_manifest(target) != source_leases):
            raise InstallError("Existing migration marker names different durable leased work")
        return marker
    backup = (validated_migration_backup(source, prior_backup, deployment)
              if prior_backup is not None else backup_runtime(source, deployment))
    for relative in DURABLE_RUNTIME_DIRECTORIES:
        copy_durable_directory(source / relative, target / relative)
    for relative in DURABLE_RUNTIME_FILES:
        source_file = source / relative
        if source_file.is_file() and not source_file.is_symlink():
            shutil.copy2(source_file, target / relative)
    if durable_leased_input_manifest(target) != source_leases:
        raise InstallError("Migration changed the exact durable leased-input set")
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
        "source_leased_inputs": source_leases,
        "leased_input_standing": (
            "durable-restart-work-copied"
            if source_leases else "no-leased-input"
        ),
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


def hold_leased_inputs_for_cold_restore(
        runtime: pathlib.Path, account: pwd.struct_passwd) -> dict | None:
    """Keep exact restart work dormant while a candidate release proves restore."""
    manifest = durable_leased_input_manifest(runtime)
    if not manifest:
        return None
    leased = runtime / "leased"
    held = runtime / f".release-transition-leased-{os.getpid()}"
    if held.exists():
        raise InstallError(f"Release-transition lease hold already exists: {held}")
    leased.rename(held)
    leased.mkdir(mode=0o700)
    os.chown(leased, account.pw_uid, account.pw_gid)
    descriptor = os.open(runtime, os.O_RDONLY)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)
    return {"path": held, "manifest": manifest}


def restore_held_leased_inputs(runtime: pathlib.Path, hold: dict | None,
                               account: pwd.struct_passwd) -> list[dict]:
    if hold is None:
        return []
    held = hold.get("path")
    expected = hold.get("manifest")
    leased = runtime / "leased"
    if (not isinstance(held, pathlib.Path) or held.parent != runtime
            or not held.name.startswith(".release-transition-leased-")
            or not isinstance(expected, list)):
        raise InstallError("Release-transition lease hold is malformed")
    if not held.exists():
        actual = durable_leased_input_manifest(runtime)
        if actual == expected:
            return actual
        raise InstallError("Release-transition lease hold is missing")
    if held.is_symlink() or not held.is_dir():
        raise InstallError("Release-transition lease hold is not a plain directory")
    if durable_leased_input_manifest(runtime):
        raise InstallError("Candidate admitted new work while leased inputs were held")
    leased.rmdir()
    held.rename(leased)
    secure_owned_tree(leased, account)
    actual = durable_leased_input_manifest(runtime)
    if actual != expected:
        raise InstallError("Cold restore changed the exact durable leased-input set")
    descriptor = os.open(runtime, os.O_RDONLY)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)
    return actual


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


def miter_reply(result: subprocess.CompletedProcess[str], context: str) -> dict:
    try:
        reply = json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        raise child_failure(result, f"{context} returned invalid JSON") from exc
    if not isinstance(reply, dict) or reply.get("schema") != "miter-assistant-operator-result-v1":
        raise child_failure(result, f"{context} returned an invalid operator result")
    return reply


def runtime_ready(reply: dict) -> bool:
    heartbeat = reply.get("heartbeat")
    pid = reply.get("pid")
    valid_until = heartbeat.get("valid_until_epoch") if isinstance(heartbeat, dict) else None
    state = heartbeat.get("state") if isinstance(heartbeat, dict) else None
    return (
        reply.get("status") in {"running", "processing-unconfirmed"}
        and reply.get("lkg") == "verified"
        and isinstance(pid, int) and pid > 1
        and isinstance(heartbeat, dict)
        and heartbeat.get("pid") == pid
        # A process-bound starting lease prevents a legitimate native restore
        # from being killed as stale, but is deliberately not semantic
        # readiness and cannot certify a release transition.
        and state not in {
            "assistant-starting-v3", "assistant-stopped", "assistant-panicked"
        }
        and isinstance(valid_until, (int, float)) and valid_until >= time.time()
    )


def wait_runtime_ready(config: dict, application: pathlib.Path, deployment: dict,
                       petta: pathlib.Path) -> dict:
    grace = config["supervision"]["startup_grace_seconds"]
    processing = config["supervision"]["processing_lease_seconds"]
    deadline = time.monotonic() + max(grace, processing) + 15
    last: dict = {}
    while time.monotonic() < deadline:
        result = miter_command(application, deployment, petta, "status", check=False)
        if result.returncode == 0:
            last = miter_reply(result, "Miter readiness status")
            if runtime_ready(last):
                return last
            supervisor = last.get("supervisor")
            if (last.get("status") == "stopped"
                    and isinstance(supervisor, dict)
                    and supervisor.get("standing") in {"dead", "absent"}):
                break
        time.sleep(0.25)
    raise InstallError(
        "Miter did not expose a native-ready process-bound heartbeat after cold restore; "
        f"last status was {last.get('status', 'unavailable')}; "
        f"last heartbeat state was "
        f"{(last.get('heartbeat') or {}).get('state', 'unavailable')}"
    )


def stop_runtime_at_boundary(config: dict, application: pathlib.Path,
                             deployment: dict, petta: pathlib.Path) -> dict:
    result = miter_command(application, deployment, petta, "stop", check=False)
    if result.returncode != 0:
        raise child_failure(result, "Miter stop request")
    reply = miter_reply(result, "Miter stop request")
    if reply.get("status") == "stopped":
        return reply

    model_deadlines = [
        profile.get("limits", {}).get("deadline_seconds", 0)
        for profile in config["models"]["resources"]
    ]
    supervision = config["supervision"]
    timeout = max(
        supervision["processing_lease_seconds"],
        max(model_deadlines, default=0) + supervision["model_lease_margin_seconds"],
    ) + supervision["termination_grace_seconds"] + 15
    deadline = time.monotonic() + timeout
    last = reply
    while time.monotonic() < deadline:
        status = miter_command(application, deployment, petta, "status", check=False)
        if status.returncode == 0:
            last = miter_reply(status, "Miter stop-boundary status")
            if last.get("status") == "stopped":
                return last
        time.sleep(0.5)
    raise InstallError(
        "Miter did not reach an actual stopped cycle boundary within its configured "
        f"processing/model envelope; last status was {last.get('status', 'unavailable')}"
    )


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


def provision_vad_asset(config: dict, account: pwd.struct_passwd,
                        supplied_path: str | None) -> bool:
    """Install the exact licensed VAD asset without admitting it to source.

    The destination is stable private runtime state.  Existing bytes are never
    replaced implicitly: their identity and ownership must already be exact.
    """
    vad = config.get("vad")
    if not isinstance(vad, dict) or vad.get("enabled") is not True:
        return True
    asset = vad.get("asset")
    if not isinstance(asset, dict):
        raise InstallError("The enabled VAD configuration has no asset descriptor")
    relative = asset.get("relative_path")
    expected = asset.get("sha256")
    relative_path = pathlib.PurePosixPath(relative) if isinstance(relative, str) else None
    if (relative_path is None or relative_path.is_absolute()
            or relative_path.parts[:1] != ("private-assets",)
            or ".." in relative_path.parts):
        raise InstallError("The VAD asset must remain beneath runtime/private-assets")
    if not isinstance(expected, str) or len(expected) != 64:
        raise InstallError("The VAD asset has no exact SHA-256 identity")
    runtime = pathlib.Path(config["deployment"]["runtime_root"])
    destination = runtime / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        if (not destination.is_file() or destination.is_symlink()
                or sha256_file(destination) != expected
                or destination.stat().st_uid != account.pw_uid
                or stat.S_IMODE(destination.stat().st_mode) != 0o600):
            raise InstallError(
                "Existing private VAD asset has the wrong identity, ownership, or mode"
            )
        return True
    if supplied_path is None:
        return False
    source = pathlib.Path(supplied_path)
    if not source.is_absolute() or not source.is_file() or source.is_symlink():
        raise InstallError("--vad-asset must name one absolute regular file")
    if sha256_file(source) != expected:
        raise InstallError("Supplied VAD asset does not match the pinned NRC VAD 2.1 identity")
    descriptor, temporary_text = tempfile.mkstemp(
        prefix=".NRC-VAD-Lexicon-v2.1.", dir=destination.parent
    )
    temporary = pathlib.Path(temporary_text)
    try:
        with os.fdopen(descriptor, "wb") as output, source.open("rb") as input_file:
            shutil.copyfileobj(input_file, output, length=1024 * 1024)
            output.flush()
            os.fsync(output.fileno())
        if sha256_file(temporary) != expected:
            raise InstallError("Private VAD asset changed while it was being copied")
        os.chown(temporary, account.pw_uid, account.pw_gid)
        temporary.chmod(0o600)
        os.replace(temporary, destination)
        directory = os.open(destination.parent, os.O_RDONLY)
        try:
            os.fsync(directory)
        finally:
            os.close(directory)
    finally:
        temporary.unlink(missing_ok=True)
    return True


def broker_command(application: pathlib.Path, deployment: dict, command: str,
                   *, check: bool = True) -> subprocess.CompletedProcess[str]:
    operator = invoking_user(deployment["runtime_user"])
    if operator in {"root", deployment["runtime_user"]}:
        raise InstallError(
            "The Docker broker must be owned by the signed-in installing operator, "
            "not root or the dedicated runtime identity"
        )
    return run([
        command_path("swipl"), "-q", "-f", "none", "-s",
        str(application / "effect_membranes" / "workshop_broker.pl"), "--",
        command, "--config", str(pathlib.Path(deployment["broker_root"]) / "config.json"),
    ], check=check, user=operator, cwd="/private/tmp")


def provision_workshop_broker(config: dict, application: pathlib.Path,
                              account: pwd.struct_passwd) -> dict:
    """Create one operator-owned narrow broker and one runtime-readable token."""
    if os.geteuid() != 0:
        raise InstallError("Workshop broker provisioning requires the installer boundary")
    deployment = config["deployment"]
    operator = invoking_user(deployment["runtime_user"])
    if operator in {"root", deployment["runtime_user"]}:
        raise InstallError(
            "Run the installer with sudo from the macOS user that owns Docker Desktop"
        )
    operator_account = pwd.getpwnam(operator)
    broker_root = pathlib.Path(deployment["broker_root"])
    if broker_root.is_symlink() or (broker_root.exists() and not broker_root.is_dir()):
        raise InstallError("Workshop broker root is not a safe directory")
    broker_root.mkdir(parents=True, exist_ok=True)
    os.chown(broker_root, operator_account.pw_uid, operator_account.pw_gid)
    broker_root.chmod(0o700)

    token_path = broker_root / "token"
    if token_path.exists():
        if (not token_path.is_file() or token_path.is_symlink()
                or token_path.stat().st_uid != operator_account.pw_uid
                or stat.S_IMODE(token_path.stat().st_mode) != 0o600):
            raise InstallError("Existing workshop broker token has unsafe ownership or mode")
        token = token_path.read_text(encoding="utf-8").strip()
        if len(token) < 32:
            raise InstallError("Existing workshop broker token is invalid")
    else:
        token = secrets.token_urlsafe(48)
        descriptor = os.open(token_path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        try:
            os.write(descriptor, token.encode("utf-8") + b"\n")
            os.fsync(descriptor)
        finally:
            os.close(descriptor)
        os.chown(token_path, operator_account.pw_uid, operator_account.pw_gid)

    runtime = pathlib.Path(deployment["runtime_root"])
    relative = config["growth_environment"]["workshop"]["broker"][
        "credential_reference"]["relative_path"]
    runtime_token = runtime / relative
    if runtime_token.exists():
        if (not runtime_token.is_file() or runtime_token.is_symlink()
                or runtime_token.stat().st_uid != account.pw_uid
                or stat.S_IMODE(runtime_token.stat().st_mode) != 0o600
                or runtime_token.read_text(encoding="utf-8").strip() != token):
            raise InstallError("Runtime workshop broker token is unsafe or disagrees with the broker")
    else:
        store_secret(runtime, relative, token, account)

    old_config = broker_root / "config.json"
    if old_config.exists():
        old_stop = broker_command(application, deployment, "stop", check=False)
        if old_stop.returncode not in {0, 3}:
            raise child_failure(old_stop, "Existing workshop broker stop")
    workshop = config["growth_environment"]["workshop"]
    broker = workshop["broker"]
    document = {
        "schema": "miter-workshop-broker-config-v1",
        "origin": broker["origin"],
        "port": urllib.parse.urlparse(broker["origin"]).port,
        "root": str(broker_root),
        "token_path": str(token_path),
        "pid_path": str(broker_root / "pid.json"),
        "log_path": str(broker_root / "broker.log"),
        "docker_path": command_path("docker"),
        "image": workshop["image"],
        "platform": workshop["platform"],
        "network": workshop["network"],
        "root_filesystem": workshop["root_filesystem"],
        "memory_megabytes": workshop["memory_megabytes"],
        "cpus": workshop["cpus"],
        "pids_limit": workshop["pids_limit"],
        "maximum_request_bytes": broker["maximum_request_bytes"],
        "standing": "non-cognitive-exact-workshop-observer",
    }
    temporary = broker_root / f".config.{os.getpid()}.json"
    temporary.write_text(json.dumps(document, sort_keys=True) + "\n", encoding="utf-8")
    os.chown(temporary, operator_account.pw_uid, operator_account.pw_gid)
    temporary.chmod(0o600)
    os.replace(temporary, old_config)

    start = broker_command(application, deployment, "start", check=False)
    if start.returncode != 0:
        raise child_failure(start, "Workshop broker start")
    try:
        reply = json.loads(start.stdout)
    except json.JSONDecodeError as exc:
        raise child_failure(start, "Workshop broker returned invalid JSON") from exc
    if reply.get("status") not in {"started", "already-running"}:
        raise InstallError("Workshop broker did not become ready")
    return {
        "schema": "miter-workshop-broker-installation-v1",
        "status": reply["status"],
        "origin": broker["origin"],
        "operator": operator,
        "runtime_has_docker_socket": False,
    }


def operator_wrapper_text(application: pathlib.Path, deployment: dict,
                          petta: pathlib.Path, operator: str) -> str:
    runtime = deployment["runtime_root"]
    user = deployment["runtime_user"]
    broker = application / "effect_membranes" / "workshop_broker.pl"
    broker_config = pathlib.Path(deployment["broker_root"]) / "config.json"
    return f'''#!/bin/sh
set -eu
cd /private/tmp
command=${{1:-}}
if [ "$command" = start ]; then
  /usr/bin/sudo -u {operator} -H {shell_quote(command_path('swipl'))} -q -f none \
    -s {shell_quote(str(broker))} -- start --config {shell_quote(str(broker_config))} \
    >/dev/null
fi
if [ "$(/usr/bin/id -un)" = {user} ]; then
  run_as_runtime=
else
  run_as_runtime="/usr/bin/sudo -u {user} -H"
fi
if [ "$command" = stop ] || [ "$command" = panic ]; then
  set +e
  $run_as_runtime /usr/bin/env \\
    MITER_PETTA_MAIN={shell_quote(str(petta / 'src' / 'main.pl'))} \\
    MITER_SWIPL_LD={shell_quote(command_path('swipl-ld'))} \\
    {shell_quote(str(application / 'bin' / 'miter'))} "$@" \\
    --runtime-root {shell_quote(runtime)}
  result=$?
  set -e
  /usr/bin/sudo -u {operator} -H {shell_quote(command_path('swipl'))} -q -f none \\
    -s {shell_quote(str(broker))} -- stop --config {shell_quote(str(broker_config))} \\
    >/dev/null 2>&1 || true
  exit "$result"
fi
exec $run_as_runtime /usr/bin/env \\
  MITER_PETTA_MAIN={shell_quote(str(petta / 'src' / 'main.pl'))} \\
  MITER_SWIPL_LD={shell_quote(command_path('swipl-ld'))} \\
  {shell_quote(str(application / 'bin' / 'miter'))} "$@" \\
  --runtime-root {shell_quote(runtime)}
'''


def install_operator_wrapper(application: pathlib.Path, deployment: dict,
                             petta: pathlib.Path) -> None:
    if os.geteuid() != 0:
        raise InstallError("Run install with sudo so it can install the operator command")
    operator = invoking_user(deployment["runtime_user"])
    if operator in {"root", deployment["runtime_user"]}:
        raise InstallError("The installed operator must retain the Docker-owning macOS user")
    text = operator_wrapper_text(application, deployment, petta, operator)
    operator_path = pathlib.Path(deployment["operator_path"])
    operator_path.parent.mkdir(parents=True, exist_ok=True)
    operator_path.write_text(text, encoding="utf-8")
    os.chown(operator_path, 0, 0)
    operator_path.chmod(0o755)


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
    vad = config.get("vad")
    vad_asset = vad.get("asset") if isinstance(vad, dict) else None
    vad_relative = vad_asset.get("relative_path") if isinstance(vad_asset, dict) else None
    vad_path = runtime / vad_relative if isinstance(vad_relative, str) else None
    try:
        vad_ready = (
            vad_path is not None
            and vad_path.is_file() and not vad_path.is_symlink()
            and sha256_file(vad_path) == vad_asset.get("sha256")
            and account is not None and vad_path.stat().st_uid == account.pw_uid
            and stat.S_IMODE(vad_path.stat().st_mode) == 0o600
        )
    except (OSError, PermissionError):
        vad_ready = False
    checks["vad_asset"] = "private-present" if vad_ready else "missing-or-invalid"
    checks["chroma"] = "healthy" if endpoint_available(config["memory"]["chroma"]["origin"] + "/api/v2/heartbeat") else "unavailable"
    checks["mattermost"] = "healthy" if endpoint_available(config["mattermost"]["origin"] + "/api/v4/system/ping") else "unavailable"
    if application and petta and account and runtime_ready:
        checks["workshop_broker"] = "stopped-or-invalid"
        result = miter_command(application, deployment, petta, "status", check=False)
        try:
            status = json.loads(result.stdout or "{}")
            broker = status.get("workshop_broker", {})
            checks["workshop_broker"] = (
                "running" if isinstance(broker, dict) and broker.get("standing") == "ready"
                else "stopped-or-invalid"
            )
            checks["miter"] = f"{status.get('status','unknown')};lkg={status.get('lkg','unknown')}"
        except json.JSONDecodeError:
            checks["miter"] = "operator-invalid"
    complete = all(
        value in {"present-non-admin", "private-present", "healthy", "running"}
        or value.startswith(("running;lkg=verified", "stopped;lkg=verified"))
        for value in checks.values()
    )
    return {"schema": "miter-installation-validation-v1", "complete": complete, "checks": checks}


def print_commands(config: dict) -> None:
    operator = shell_quote(config["deployment"]["operator_path"])
    print("Ordinary Miter operator commands:")
    print(f"  sudo {operator} start")
    print(f"  sudo {operator} status")
    print(f"  sudo {operator} stop")
    print(f"  sudo {operator} panic")
    print(f"  sudo {operator} model-selection")
    print("Application release commands (from the clean source repository):")
    print("  sudo ./install_miter.py upgrade")
    print("  sudo ./install_miter.py rollback-release")


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
        "install_root": deployment["install_root"],
        "runtime_root": deployment["runtime_root"],
        "application_root": deployment["application_root"],
        "dependency_root": deployment["dependency_root"],
        "services_root": deployment["services_root"],
        "backup_root": deployment["backup_root"],
        "broker_root": deployment["broker_root"],
        "operator_path": deployment["operator_path"],
        "configured_ports": {
            "mattermost": "occupied" if mattermost else "available",
            "chroma": "occupied" if chroma else "available",
        },
        "default_service_action": "refuse-unowned-collision;create-isolated-when-available",
        "migration_alternative": "--reuse-local-services preserves the explicitly selected healthy local services",
        "private_vad_asset": "required-by-exact-SHA-256; supply with --vad-asset; never copied into source",
        "destructive_actions": [],
    }


def remove_transition_runtime(path: pathlib.Path, expected_parent: pathlib.Path,
                              expected_prefix: str, *,
                              allow_durable_leases: bool = False) -> None:
    """Remove only a stopped, derived runtime created by this transition."""
    if (path.parent != expected_parent or not path.name.startswith(expected_prefix)
            or path.is_symlink() or not path.is_dir()):
        raise InstallError(f"Refusing to remove unexpected transition runtime: {path}")
    ensure_runtime_stopped(path, allow_durable_leases=allow_durable_leases)
    shutil.rmtree(path)


def restore_previous_release_after_failure(
        config: dict, deployment: dict, petta: pathlib.Path,
        account: pwd.struct_passwd, previous_application: pathlib.Path,
        source_runtime: pathlib.Path, failed_runtime: pathlib.Path | None,
        expected_checkpoint: str, expected_runtime_id: str) -> None:
    """Restore the pre-transition runtime and operator without inventing state."""
    runtime = pathlib.Path(deployment["runtime_root"])
    if runtime.exists():
        raise InstallError(
            "Release rollback cannot restore over an occupied live runtime path"
        )
    source_runtime.rename(runtime)
    if verify_runtime_checkpoint(runtime) != expected_checkpoint:
        raise InstallError("Restored predecessor runtime checkpoint changed")
    if json_document(runtime / "runtime.json").get("runtime_id") != expected_runtime_id:
        raise InstallError("Restored predecessor runtime identity changed")
    if not runtime_lkg_matches_application(runtime, previous_application):
        raise InstallError("Restored predecessor runtime no longer matches its release")
    provision_workshop_broker(config, previous_application, account)
    install_operator_wrapper(previous_application, deployment, petta)
    started = miter_command(previous_application, deployment, petta, "start",
                            check=False)
    if started.returncode != 0:
        raise child_failure(started, "Predecessor release recovery start")
    wait_runtime_ready(config, previous_application, deployment, petta)
    if failed_runtime is not None and failed_runtime.exists():
        failed_leases = durable_leased_input_manifest(failed_runtime)
        if failed_leases:
            if failed_leases != durable_leased_input_manifest(runtime):
                raise InstallError(
                    "Failed candidate and restored predecessor disagree on durable leased work"
                )
            # A failed candidate containing restart-owned work is retained for
            # explicit recovery review even when it byte-matches the restored
            # predecessor.  Automatic deletion is not an acceptable failure
            # response for a carrier that has not yet reached a checkpoint.
            return
        remove_transition_runtime(
            failed_runtime, runtime.parent, "runtime.failed-release-"
        )


def transition_application_release(config: dict, target_application: pathlib.Path,
                                   transition: str) -> dict:
    """Move one durable runtime across an immutable application release.

    This is finite installation/recovery machinery.  It never selects a
    movement or interprets contact.  Polling is suspended during cold restore,
    and the active checkpoint must remain byte-identical before external
    contact is re-enabled.
    """
    if os.geteuid() != 0:
        raise InstallError("Application release transitions must run with sudo")
    require_supported_host()
    deployment = config["deployment"]
    preflight_services(config, reuse=True)
    account = ensure_runtime_account(deployment["runtime_user"])
    ensure_install_root(deployment, account)
    petta = install_petta(deployment)
    ensure_workshop_image(config)
    runtime = pathlib.Path(deployment["runtime_root"])
    if not runtime_marker_valid(runtime):
        raise InstallError("No complete installed Miter runtime is available to transition")
    current_application = active_application(deployment, runtime)
    if current_application == target_application:
        return {
            "schema": "miter-application-release-transition-v1",
            "status": "already-active",
            "transition": transition,
            "active_release": release_identity(current_application),
            "runtime": str(runtime),
        }

    state = read_release_state(deployment)
    if state is not None and state.get("active_release") != release_identity(current_application):
        raise InstallError("Release-state marker disagrees with the live runtime LKG")

    stop_runtime_at_boundary(config, current_application, deployment, petta)
    source_leases = ensure_runtime_stopped(
        runtime, allow_durable_leases=True
    )
    checkpoint_before = verify_runtime_checkpoint(runtime)
    runtime_before = json_document(runtime / "runtime.json")
    runtime_id = runtime_before.get("runtime_id")
    if not isinstance(runtime_id, str) or not runtime_id:
        raise InstallError("The live runtime has no durable identity")

    timestamp = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    source_runtime = runtime.with_name(
        f"runtime.release-source-{release_identity(current_application)[:12]}-"
        f"{timestamp}-{os.getpid()}"
    )
    if source_runtime.exists():
        raise InstallError(f"Release source preservation path already exists: {source_runtime}")
    runtime.rename(source_runtime)
    failed_runtime: pathlib.Path | None = None
    migration: dict | None = None
    poll_prior: bytes | None = None
    poll_suspended = False
    lease_hold: dict | None = None
    candidate_started = False
    try:
        bootstrap = miter_command(target_application, deployment, petta,
                                  "install", check=False)
        if bootstrap.returncode != 0:
            raise child_failure(bootstrap, "Candidate release runtime bootstrap")
        bootstrap_reply = miter_reply(bootstrap, "Candidate release runtime bootstrap")
        if bootstrap_reply.get("status") != "installed":
            raise InstallError(
                "Candidate release runtime bootstrap did not create a fresh runtime: "
                f"{bootstrap_reply.get('status', 'unknown')}"
            )
        migration = migrate_runtime_state(
            source_runtime, runtime, deployment, account,
            allow_durable_leases=True
        )
        if migration.get("standing") != "durable-state-copied-awaiting-cold-restore":
            raise InstallError("Candidate release migration did not reach its restore boundary")
        if not provision_vad_asset(config, account, None):
            raise InstallError("Candidate release did not retain the exact private VAD asset")
        missing = provision_credentials(config, account, True)
        if missing:
            raise InstallError(
                "Candidate release could not recover private credentials: "
                + ", ".join(missing)
            )
        broker = provision_workshop_broker(config, target_application, account)
        lease_hold = hold_leased_inputs_for_cold_restore(runtime, account)
        poll_prior = suspend_surface_poll(runtime, account)
        poll_suspended = True
        started = miter_command(target_application, deployment, petta, "start",
                                check=False)
        if started.returncode != 0:
            raise child_failure(started, "Candidate release cold-restore start")
        candidate_started = True
        start_reply = miter_reply(started, "Candidate release cold-restore start")
        if start_reply.get("mattermost_preflight") != "ready":
            raise InstallError("Candidate release Mattermost identity preflight was held")
        wait_runtime_ready(config, target_application, deployment, petta)
        stop_runtime_at_boundary(config, target_application, deployment, petta)
        candidate_started = False
        migration = mark_migration_restored(runtime, migration, account)
        if verify_runtime_checkpoint(runtime) != checkpoint_before:
            raise InstallError("Candidate release cold restore changed the active checkpoint")
        if json_document(runtime / "runtime.json").get("runtime_id") != runtime_id:
            raise InstallError("Candidate release changed the durable runtime identity")
        restored_leases = restore_held_leased_inputs(runtime, lease_hold, account)
        lease_hold = None
        if restored_leases != source_leases:
            raise InstallError("Candidate release did not preserve exact restart-owned work")
        restore_surface_poll(runtime, poll_prior, account)
        poll_suspended = False

        install_operator_wrapper(target_application, deployment, petta)
        live = miter_command(target_application, deployment, petta, "start",
                             check=False)
        if live.returncode != 0:
            raise child_failure(live, "Candidate release live start")
        candidate_started = True
        ready = wait_runtime_ready(config, target_application, deployment, petta)
        report = validate(config, target_application, petta)
        if not report.get("complete"):
            raise InstallError("Candidate release did not pass complete installed validation")
        carried_input_standings = verify_carried_inputs_present(
            runtime, source_leases
        )
        backup = pathlib.Path(migration["backup"])
        release_state = write_release_state(
            deployment, active=target_application, previous=current_application,
            transition=transition, checkpoint_sha256=checkpoint_before,
            runtime_id=runtime_id, backup=backup
        )
        remove_transition_runtime(
            source_runtime, runtime.parent, "runtime.release-source-",
            allow_durable_leases=True
        )
        report.update({
            "schema": "miter-application-release-transition-v1",
            "status": "application-release-active",
            "transition": transition,
            "active_release": release_identity(target_application),
            "previous_release": release_identity(current_application),
            "runtime": str(runtime),
            "runtime_id": runtime_id,
            "checkpoint_active_sha256": checkpoint_before,
            "migration": migration,
            "release_state": release_state,
            "heartbeat": ready.get("heartbeat"),
            "workshop_broker": broker,
            "carried_inputs": carried_input_standings,
        })
        return report
    except Exception as original:
        if candidate_started and runtime.exists():
            try:
                stop_runtime_at_boundary(config, target_application,
                                         deployment, petta)
            except Exception as stop_error:
                raise InstallError(
                    "Candidate release failed and could not be stopped safely; "
                    f"predecessor remains preserved at {source_runtime}; "
                    f"original failure: {original}; stop failure: {stop_error}"
                ) from stop_error
        if runtime.exists():
            if lease_hold is not None:
                restore_held_leased_inputs(runtime, lease_hold, account)
                lease_hold = None
            if poll_suspended:
                restore_surface_poll(runtime, poll_prior, account)
                poll_suspended = False
            ensure_runtime_stopped(runtime, allow_durable_leases=True)
            failed_runtime = runtime.with_name(
                f"runtime.failed-release-{release_identity(target_application)[:12]}-"
                f"{timestamp}-{os.getpid()}"
            )
            if failed_runtime.exists():
                raise InstallError(
                    f"Candidate release preservation path already exists: {failed_runtime}"
                ) from original
            runtime.rename(failed_runtime)
        try:
            restore_previous_release_after_failure(
                config, deployment, petta, account, current_application,
                source_runtime, failed_runtime, checkpoint_before, runtime_id
            )
        except Exception as recovery_error:
            raise InstallError(
                "Application release transition failed and automatic predecessor "
                f"recovery also failed; original failure: {original}; "
                f"recovery failure: {recovery_error}; preserved source: {source_runtime}; "
                f"failed candidate: {failed_runtime}"
            ) from recovery_error
        raise InstallError(
            "Application release transition failed; the predecessor release was "
            f"restored and restarted without checkpoint change: {original}"
        ) from original


def upgrade(config: dict) -> dict:
    if os.geteuid() != 0:
        raise InstallError("Application release upgrade must run with sudo")
    deployment = config["deployment"]
    identity = source_identity()
    target = install_application(deployment, identity)
    return transition_application_release(config, target, "upgrade")


def rollback_release(config: dict) -> dict:
    if os.geteuid() != 0:
        raise InstallError("Application release rollback must run with sudo")
    deployment = config["deployment"]
    state = read_release_state(deployment)
    if state is None or not isinstance(state.get("previous_release"), str):
        raise InstallError("No verified predecessor application release is recorded")
    target = (pathlib.Path(deployment["application_root"]) / "releases"
              / state["previous_release"])
    return transition_application_release(config, target, "rollback")


def install(config: dict, reuse_services: bool, import_keychain: bool,
            migrate_runtime: str | None, vad_asset: str | None) -> dict:
    if os.geteuid() != 0:
        raise InstallError("Run this command with sudo; plan and validate are read-only")
    require_supported_host()
    deployment = config["deployment"]
    identity = source_identity()
    preflight_services(config, reuse=reuse_services)
    account = ensure_runtime_account(deployment["runtime_user"])
    ensure_install_root(deployment, account)
    petta = install_petta(deployment)
    application = install_application(deployment, identity)
    service_standing = install_services(config, reuse=reuse_services)
    workshop_image = ensure_workshop_image(config)
    create_private_runtime_parent(deployment, account)
    runtime = pathlib.Path(deployment["runtime_root"])
    migration_source = pathlib.Path(migrate_runtime).resolve() if migrate_runtime else None
    failed_migration_recovery = (
        prepare_failed_migration_retry(runtime, migration_source, deployment, application)
        if migration_source is not None and runtime.exists() else None
    )
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
    if migration_source is not None:
        source_runtime = migration_source
        if source_runtime == runtime.resolve():
            raise InstallError("Migration source and destination are identical")
        prior_backup = (pathlib.Path(failed_migration_recovery["backup"])
                        if failed_migration_recovery else None)
        migration = migrate_runtime_state(
            source_runtime,runtime,deployment,account,prior_backup=prior_backup
        )
        migration_pending_restore = (
            migration.get("standing") ==
            "durable-state-copied-awaiting-cold-restore"
        )
    vad_ready = provision_vad_asset(config, account, vad_asset)
    missing = provision_credentials(config, account, import_keychain)
    if not vad_ready:
        missing.append("NRC VAD 2.1 private lexical asset (--vad-asset)")
    if missing:
        return {
            "schema": "miter-installation-result-v1",
            "status": "awaiting-private-inputs",
            "application": str(application),
            "petta": str(petta),
            "runtime": str(runtime),
            "services": service_standing,
            "recovered_incomplete_runtime": (
                str(recovered_incomplete_runtime)
                if recovered_incomplete_runtime else None
            ),
            "migration": migration,
            "failed_migration_recovery": failed_migration_recovery,
            "missing": missing,
            "next": "Run the same install command interactively to finish without replacing existing state.",
        }
    broker_standing = provision_workshop_broker(config, application, account)
    prior_poll = (
        suspend_surface_poll(runtime,account)
        if migration_pending_restore else None
    )
    cold_restore_started = False
    try:
        start = miter_command(application, deployment, petta, "start", check=False)
        if start.returncode != 0:
            raise child_failure(start,
              "Miter could not begin its migration cold-restore validation")
        start_reply = miter_reply(start, "Miter migration cold-restore start")
        if start_reply.get("status") not in {"started", "starting", "running"}:
            raise InstallError(
                "Miter migration cold-restore start was held: "
                f"{start_reply.get('status', 'unknown')}"
            )
        cold_restore_started = True
        if start_reply.get("mattermost_preflight") != "ready":
            stop_runtime_at_boundary(config, application, deployment, petta)
            raise InstallError(
                "Mattermost bot/group identity could not be validated; installation remains held"
            )
        wait_runtime_ready(config, application, deployment, petta)
        stop_runtime_at_boundary(config, application, deployment, petta)
        cold_restore_started = False
        if migration_pending_restore:
            migration = mark_migration_restored(runtime,migration,account)
    except Exception:
        if cold_restore_started:
            miter_command(application, deployment, petta, "stop", check=False)
        broker_command(application, deployment, "stop", check=False)
        raise
    finally:
        if migration_pending_restore:
            restore_surface_poll(runtime,prior_poll,account)
    install_operator_wrapper(application, deployment, petta)
    started = miter_command(application, deployment, petta, "start", check=False)
    if started.returncode != 0:
        raise child_failure(started, "Miter CLI supervisor could not start")
    started_reply = miter_reply(started, "Miter final CLI start")
    if started_reply.get("status") not in {"started", "starting", "running"}:
        raise InstallError(
            f"Miter final CLI start was held: {started_reply.get('status', 'unknown')}"
        )
    try:
        wait_runtime_ready(config, application, deployment, petta)
    except Exception:
        miter_command(application, deployment, petta, "stop", check=False)
        broker_command(application, deployment, "stop", check=False)
        raise
    report = validate(config, application, petta)
    report.update({
        "status": "installed-and-started" if report["complete"] else "installed-validation-held",
        "application": str(application), "petta": str(petta),
        "runtime": str(runtime), "services": service_standing,
        "workshop_image": workshop_image,
        "workshop_broker": broker_standing,
        "recovered_incomplete_runtime": (
            str(recovered_incomplete_runtime)
            if recovered_incomplete_runtime else None
        ),
        "migration": migration,
    })
    if report["complete"] and failed_migration_recovery is not None:
        report["failed_migration_recovery"] = remove_verified_failed_runtime(
            failed_migration_recovery, runtime
        )
    else:
        report["failed_migration_recovery"] = failed_migration_recovery
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
    install_parser.add_argument("--vad-asset", metavar="ABSOLUTE_PATH",
                                help="Provision the exact licensed NRC VAD 2.1 file into private runtime state")
    subparsers.add_parser("validate", help="Read-only installation validation")
    subparsers.add_parser("commands", help="Print ordinary operator commands")
    subparsers.add_parser(
        "upgrade",
        help="Cold-restore the live mind under the exact committed source release",
    )
    subparsers.add_parser(
        "rollback-release",
        help="Carry current continuity back through the verified predecessor release",
    )
    args = parser.parse_args()
    try:
        config = load_config()
        if args.command == "plan":
            result = plan(config)
        elif args.command == "install":
            result = install(config, args.reuse_local_services,
                             args.import_keychain_credentials,
                             args.migrate_runtime, args.vad_asset)
        elif args.command == "validate":
            result = validate(config)
        elif args.command == "upgrade":
            result = upgrade(config)
        elif args.command == "rollback-release":
            result = rollback_release(config)
        else:
            print_commands(config)
            return 0
        print(json.dumps(result, indent=2, sort_keys=True))
        if args.command == "install" and result.get("status") == "installed-and-started":
            print_commands(config)
        return 0 if args.command != "validate" or result.get("complete") else 1
    except InstallError as exc:
        print(json.dumps({"schema": "miter-installation-error-v1", "error": str(exc)}, sort_keys=True), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
