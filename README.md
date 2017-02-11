# Broken Forward Exports on Windows 7 (and maybe later versions?)

## Summary

This repo demonstrates a "bug" in the way *Forward Exports* are handled
on Windows 7, subtly breaking app-local deployments of the Universal CRT.
For information regarding *Forward Exports*, see
https://blogs.msdn.microsoft.com/oldnewthing/20060719-24/?p=30473.

In the real world, this led to the following bug:
https://github.com/mumble-voip/mumble/issues/2837

Our program has a small loader program that loads our main app logic from
a DLL living in a subdirectory. This DLL is loaded with `LoadLibraryEx()` 
with `LOAD_WITH_ALTERED_SEARCH_PATH` on. The universal CRT is deployed to the
same directory as the app logic DLL.

When running this app on Windows 7, it can't run. Because it can't find
ucrtbase.dll. This DLL is loaded via a forward export in
`api-ms-win-crt-runtime-l1-1-0.dll`.

The pattern for loading ucrtbase.dll is:

1. Try next to the .exe
2. Try 32-bit system directory
3. Try 16-bit system directory
4. Try Windows folder
5. Try CWD
6. Try `%PATH%` (seemingly)...

This matches the Standard Search Order For Desktop Applications, from
https://msdn.microsoft.com/en-us/library/ms682586.aspx

That is, DLLs that use *Forward Exports* do not honor the
`LOAD_WITH_ALTERED_SEARCH_PATH` flag in `LoadLibraryEx()`.

This means the program can't start, because it can't load the
ucrtbase.dll that lives next to the app-logic DLL.

The work-around in our case seems to be to set the directory
that contains the app-logic DLL as the working directory.
That way, even when Windows falls back to using the *Standard
Search Order For Desktop Applications*

## About the program in this repo

The program in this repo tries to imitate the app structure mentioned
in the summary above. It is meant to show the issue in a reproducible manner.

- There is a `main.exe` application loader.
- There is `app.dll`, containing the application logic.
- `app.dll` links to `dummycrt.dll` (which imitates an app stub DLL from the UCRT, i.e. `api-ms-win-crt-runtime-l1-1-0.dll`.)
- `dummycrt.dll` has a *Forward Export* to crtimpl.dll containing the actual implementation. (This imiates `ucrtbase.dll`.)

## Build and test

Building the example requires VS2015.

To build, ope a command prompt and run `build.cmd`.

This produces the following files in `out`:

  - `out/main.exe`
  - `out/crtdir/app.dll`
  - `out/crtdir/crtimpl.dll`
  - `out/crtdir/dummycrt.dll`

Here's what they do:

- `main.exe` - Loads app.dll. Shows an alert dialog on failure/success.
- `app.dll` - Imports AreYouCRT from dummycrt.dll and calls it in DllMain. Dynamically linked to dummycrt.dll.
- `dummycrt.dll` - Exports AreYouCRT via *Forward Export* to `crtimpl.AreYouCRT`.
- `crtimpl.dll` - Implements `AreYouCRT`, a simple function that returns a bool and takes no arguments. Always returns true.

## Results on Windows 7

Status: **<span style="color: red">Failure</span>**

When run on Windows 7 SP 1:

An alert dialog (from Windows?) is shown. It shows:

    main.exe - Entry Point Not Found
    The procedure entry point crtimpl.AreYouCRT could not be located in the dynamic link library dummycrt.dll.
    [OK]

(Click OK)

An alert dialog from main.exe is shown, saying that app.dll could not be loaded:

    Failure
    Failed to load app.dll
    [OK]

OK -- so, loading app.dll this way doesn't work on Windows 7.

Next, try copying crtimpl.dll from `crtdir`, and placing it next to `main.exe`.

Running main.exe now, instead, works, giving us the following success alert from main.exe:

    OK
    Everything's OK!
    [OK]

## Results on Windows 10 (1607, 14393.693)

Status: **<span style="color: green">OK</span>**

On Windows 10 (1607, 14393.693), simply run main.exe.

You'll immediately see the success alert dialog:

Running main.exe now, instead, works, giving us the following success alert from main.exe:

    OK
    Everything's OK!
    [OK]

So everything's fine on there.
