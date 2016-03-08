# BRCybertron CreationMatrix

CreationMatrix is an iOS application to show how [BRCybertron][BRCybertron] is used
to execute XSLT 1.0 transforms.

![](https://raw.githubusercontent.com/wiki/Blue-Rocket/BRCybertron/images/creation-matrix-screens.png)

# Providing XML and XSL files

Simply copy any XML and XSL files you'd like to use into the **MatrixResources**
directory and rebuild the app. When the app runs, any file included there will become
available for choosing.

# Running

Tap on the XML field to select which XML to use as input to the transform, and tap
on the XSL field to select which XSLT to use.

## Input parameters

You can add any number of string input parameters to the XSLT transformation by tapping
on the ⒫ button.

## JSON output syntax highlighting

If the XSL file name includes `to-json` then JSON syntax highlighting can be activated
by tapping on the ✐ button:

![](https://raw.githubusercontent.com/wiki/Blue-Rocket/BRCybertron/images/creation-matrix-json-output.png)

  [BRCybertron]:  https://github.com/Blue-Rocket/BRCybertron
