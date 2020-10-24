ObjC.import('stdlib');

var app = Application.currentApplication()
app.includeStandardAdditions = true;

var alfredApp = Application('com.runningwithcrayons.Alfred');
var bundleId = $.getenv('alfred_workflow_bundleid')
var keychainItem = $.getenv('keychainItem')

if (! keychainItem) {
    keychainItem = "KPass_AlfredWorkflow"
}


try {
    // Ask for KeepasxXC Database
    var database = app.chooseFile({
        withPrompt: "Please select the KeepassXC database to use:",
        multipleSelectionsAllowed: false,
        ofType: ["dyn.ah62d4rv4ge8003dcta"] //.kdbx extension type identifier
    })
	// ofType was found with the osascript (AS):
	// set dbFile to choose file with prompt "Select .kdbx file:"
	// info for dbFile

    // Ask for a keychain
    var keychains = app.doShellScript("security list-keychains -d user | awk '{print substr($1, 2, length($1) - 2);}'").split('\r')
    var keychain = app.chooseFromList(keychains, {
        withPrompt: "Select the keychain to store the password:",
        emptySelectionAllowed: false,
        multipleSelectionAllowed: false
    });
	keychain = keychain[0]

    // Ask for KeepassXC Database password
    var response = app.displayDialog("KeePassXC Database password", {
        defaultAnswer: "",
        buttons: ["Cancel", "Continue"],
        defaultButton: "Continue",
        hiddenAnswer: true,
        withTitle: "Please introduce the Database Password",
        withIcon: Path("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Lockedicon.icns")
    });

    // Get password and esscape it
    password = response.textReturned.replace(/\\/g, '\\\\').replace(/\"/g, '\\"');
    
    // Create a new password
    response = app.doShellScript("security add-generic-password -a $(id -un) -c 'kaiw' -C 'kaiw' -D 'KeepasXC Integration' -j 'Alfred KeepasXC Integration Database' -s \""+ keychainItem + "\" -w \"" + password + "\" -U " + keychain);

    // Ask for KeepassXC Keyfile
    var response = app.displayDialog("KeePassXC Database Keyfile", {
        defaultAnswer: "",
        buttons: ["Cancel", "Continue"],
        defaultButton: "Continue",
        hiddenAnswer: false,
        withTitle: "[Optionally]ÊPlease introduce the path of the keyfile",
        withIcon: Path("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Lockedicon.icns")
    });

    // Get keyfile if any
    keePassKeyFile = response.textReturned.replace(/\\/g, '\\\\').replace(/\"/g, '\\"');

    // Configure Alfred env variables
    alfredApp.setConfiguration('keychain', {
        toValue: keychain.replace(/(^")|("$)/,""),
        inWorkflow: bundleId,
        exportable: false
    });
    
    alfredApp.setConfiguration('keychainItem', {
        toValue: keychainItem.toString(),
        inWorkflow: bundleId,
        exportable: true
    });
    
    alfredApp.setConfiguration('keePassKeyFile', {
        toValue: keePassKeyFile.toString(),
        inWorkflow: bundleId,
        exportable: false
    });

    alfredApp.setConfiguration('database', {
        toValue: database.toString(),
        inWorkflow: bundleId,
        exportable: false
    });

    // Done
    app.displayDialog("KPass Workflow configured correctly", {
		buttons: ["Ok"],
		defaultButton: "Ok"
	});
    //    displayAlert: 	});

}
catch (err) {
    app.displayDialog("KPass Workflow could not be configured: "+ err.message, {
		buttons: ["Ok"],
		defaultButton: "Ok"
	});
}