#include <SWI-Prolog.h>
#include <SWI-Stream.h>

#include <errno.h>
#include <unistd.h>

/* The Prolog store owns durability policy.  This runtime extension exposes
 * only the POSIX fsync primitive that SWI-Prolog does not publish directly. */
static foreign_t
pl_miter_posix_fsync_stream(term_t stream_term)
{
    IOSTREAM *stream;
    int descriptor;
    int sync_result;

    if (!PL_get_stream(stream_term, &stream, SIO_OUTPUT))
        return FALSE;

    if (Sflush(stream) != 0) {
        PL_release_stream(stream);
        return FALSE;
    }

    descriptor = Sfileno(stream);
    if (descriptor < 0) {
        PL_release_stream(stream);
        return FALSE;
    }

    do {
        sync_result = fsync(descriptor);
    } while (sync_result != 0 && errno == EINTR);

    PL_release_stream(stream);
    return sync_result == 0 ? TRUE : FALSE;
}

install_t
install(void)
{
    (void)PL_register_foreign("miter_posix_fsync_stream", 1,
                              pl_miter_posix_fsync_stream, 0);
}
