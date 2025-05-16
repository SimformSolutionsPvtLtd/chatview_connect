![ChatView Connect - Simform LLC.](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview_connect/master/preview/banner.png)

# ChatView Connect

[![Build](https://github.com/SimformSolutionsPvtLtd/chatview_connect/actions/workflows/flutter.yaml/badge.svg?branch=master)](https://github.com/SimformSolutionsPvtLtd/chatview_connect/actions) [![chatview_connect](https://img.shields.io/pub/v/chatview_connect?label=chatview_connect)](https://pub.dev/packages/chatview_connect)

`chatview_connect` is a specialized wrapper for [`chatview`][chatViewPackage]
package providing seamless integration with Database & Storage for your flutter chat app.

_Check out other amazing
open-source [Flutter libraries](https://simform-flutter-packages.web.app)
and [Mobile libraries](https://github.com/SimformSolutionsPvtLtd/Awesome-Mobile-Libraries) developed
by Simform Solutions!_

## Preview

<img alt="The example app running in iOS" src="https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_chatview/main/preview/chatview.gif" width="300"/>

## Features

- **Easy Setup:** Integrate with [`chatview`][chatViewPackage] in 3 steps:
    1. Initialize the package by specifying **Cloud Service** (e.g., Firebase).
    2. Set the current **User ID**.
    3. Get **`ChatManager`** and use it with [`chatview`][chatViewPackage]
- Supports **one-on-one** and **group chats** with **media uploads** *(audio not supported).*

***Note:*** *Currently, it supports only Firebase Cloud Services. Support for additional cloud
services will be included in future releases.*

## Documentation

Visit our [documentation](https://simform-flutter-packages.web.app/chatViewConnect) site for
all implementation details, usage instructions, code examples, advanced features, database &
storage structure and rules.

## Installation

```yaml
dependencies:
  chatview_connect: <latest-version>
```

**Compatibility**: This package is compatible with `chatview` versions **>= 2.4.1**

## Support

For questions, issues, or feature
requests, [create an issue](https://github.com/SimformSolutionsPvtLtd/chatview_connect/issues)
on GitHub or reach out via the GitHub Discussions tab. We're happy to help and encourage community
contributions.
To contribute documentation updates specifically, please make changes to the `doc/documentation.md`
file and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

[chatViewPackage]: https://pub.dev/packages/chatview
