# nfc writer ios app

writes twitter and contacts links to nfcs

- [firebase storage](https://firebase.google.com): enables contacts via links

- [swiftlint](https://github.com/realm/SwiftLint): lint

- [fastlane](https://fastlane.tools): automate build and release

<br></br>
### Main Screen
<img src="ReadmeScreenshots/0MainVC.PNG" alt="Main Screen" width="200">

### Twitter NFC Writing Flow
<br></br>
<img src="ReadmeScreenshots/1SearchVC.PNG" alt="Main Screen" width="200"><img src="ReadmeScreenshots/2SearchVCTwitter.PNG" alt="Main Screen" width="200"><img src="ReadmeScreenshots/3TagVCTwitter.PNG" alt="Main Screen" width="200"><img src="ReadmeScreenshots/4WriteNFCTwitter.PNG" alt="Main Screen" width="200">

### Contact NFC Writing Flow
<br></br>
<img src="ReadmeScreenshots/5WriteContact.PNG" alt="Main Screen" width="200"><img src="ReadmeScreenshots/6WriteContactVivian.PNG" alt="Main Screen" width="200"><img src="ReadmeScreenshots/7ShareOrEditContact.PNG" alt="Main Screen" width="200"><img src="ReadmeScreenshots/8EditContact.PNG" alt="Main Screen" width="200">
<br><img src="ReadmeScreenshots/9EditVivianContact.PNG" alt="Main Screen" width="200"><img src="ReadmeScreenshots/10WriteContactToNFC.PNG" alt="Main Screen" width="200">

## Getting Started

### xcode command line tools (macOS)
```
xcode-select --install 
```

### install dependencies via homebrew
```
brew install fastlane swiftlint
``` 

### fastlane setup
```
fastlane init
```

### config linting @ ```.swiftlint.yml```
