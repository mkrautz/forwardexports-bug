// Copyright 2005-2017 The Mumble Developers. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file at the root of the
// Mumble source tree or at <https://www.mumble.info/LICENSE>.

#include <windows.h>
#include <shlwapi.h>

#include <string>

// Alert shows a fatal error dialog and waits for the user to click OK.
static void Alert(LPCWSTR title, LPCWSTR msg) {
	MessageBoxW(NULL, msg, title, MB_OK|MB_ICONERROR);
}

// GetExecutableDirPath returns the directory that
// mumble.exe resides in.
static const std::wstring GetExecutableDirPath() {
	wchar_t path[MAX_PATH];

	if (GetModuleFileNameW(NULL, path, MAX_PATH) == 0)
		return std::wstring();

	if (!PathRemoveFileSpecW(path))
		return std::wstring();

	std::wstring exe_path(path);
	return exe_path.append(L"\\");
}

int main(int argc, char *argv[]) {
	std::wstring dllpath = GetExecutableDirPath();
	dllpath.append(L"crtdir\\dummycrt.dll");

	HMODULE m = LoadLibraryExW(dllpath.c_str(), NULL, LOAD_WITH_ALTERED_SEARCH_PATH);
	if (m == NULL) {
		Alert(L"Failure", L"Failed to load dummycrt.dll");
		return 1;
	}

	Alert(L"OK", L"Everything's OK!");

	return 0;
}
