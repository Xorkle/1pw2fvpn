import PackageDescription

let package = Package(
    name: "somecommandlineapp",
    dependencies: [
        .Package(url: "https://github.com/kareman/SwiftShell.git", majorVersion: 4)
    ]
)
