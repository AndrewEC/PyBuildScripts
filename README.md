# PyBuildScripts
A module containing a collection of scripts for common local build steps for some Python projects.

## Adding New Functions
The main module file is `PyBuildScripts.psm1`. All functions exported from this module come from .ps1 scripts with a name matching the function in the `Functions` folder.

To add a new exported function, such as Invoke-StaticScan, to the `PyBuildScripts.psm1` do the following:
1. Create a new file in the `./Functions` folder called `Invoke-StaticScan.ps1` (The file name must equal the function name plus the .ps1 extension.)
2. Declare a function in the new file with the name of `Invoke-StaticScan`
3. Run the `_BuildModule.ps1` script.
4. Verify the function has been copied into the `PyBuildScripts.psm1` file.

## Removing Functions
To remove an existing function just delete the associated file in the `Functions` folder and re-run the `_BuildModule.ps1` script. Verify the function is not included in the `PyBuildScripts.psm1` file.
