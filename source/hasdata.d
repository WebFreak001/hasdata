module hasdata;

import std.stdio : File;

/// Returns true if the file or console handle has data available for read
bool hasData()(File file) @system
{
	version (Posix)
	{
		import core.sys.posix.poll : pollfd, poll, POLLIN;

		pollfd fds;
		fds.fd = file.fileno;
		fds.events = POLLIN;
		auto ret = poll(&fds, 1, 0);
		return ret == 1 && !file.eof;
	}
	else version (Windows)
	{
		import core.sys.windows.windows : GetFileType, WaitForSingleObject,
			FILE_TYPE_CHAR, WAIT_OBJECT_0;

		if (GetFileType(file.windowsHandle) == FILE_TYPE_CHAR)
			return WaitForSingleObject(file.windowsHandle, 0) == WAIT_OBJECT_0;
		else
			return !file.eof;
	}
	else
		static assert(0, "No hasData implementation for this platform");
}
