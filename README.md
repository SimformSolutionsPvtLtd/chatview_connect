![ChatView Connect - Simform LLC.](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview_connect/master/preview/banner.png)

# ChatView Connect

[![Build](https://github.com/SimformSolutionsPvtLtd/chatview_connect/actions/workflows/flutter.yaml/badge.svg?branch=master)](https://github.com/SimformSolutionsPvtLtd/chatview_connect/actions) [![chatview_connect](https://img.shields.io/pub/v/chatview_connect?label=chatview_connect)](https://pub.dev/packages/chatview_connect)

`chatview_connect` is a specialized wrapper for the [`chatview`][chatViewPackage]
package, providing seamless integration with Database & Storage for your Flutter chat app.

_Check out other amazing
open-source [Flutter libraries](https://simform-flutter-packages.web.app)
and [Mobile libraries](https://github.com/SimformSolutionsPvtLtd/Awesome-Mobile-Libraries) developed
by Simform Solutions!_

## Preview

| ChatViewList                                                                                                             | ChatView                                                                                                         |
|--------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| ![ChatViewList_Preview](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/main/preview/chatviewlist.gif) | ![ChatView Preview](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/main/preview/chatview.gif) |

## Features

- **Easy Setup:** Integrate with the [`chatview`][chatViewPackage] package in 3 steps:
    1. Initialize the package by specifying the **Cloud Service** (e.g., Firebase).
    2. Set the current **User ID**.
    3. Widget-wise controllers to use it with the [`chatview`][chatViewPackage] package:
       1. For `ChatViewList` obtain the **`ChatListManager`**
       2. For `ChatView` obtain the **`ChatManager`**
- Supports **one-on-one** and **group chats** with **media uploads** *(audio not supported).*

***Note:*** *Currently, it supports only Firebase Cloud Services. Support for additional cloud
services will be included in future releases.*

## Documentation

Visit our [documentation](https://simform-flutter-packages.web.app/chatViewConnect) site for
detailed implementation instructions, usage examples, advanced features, database &
storage structures, and rules.

## Installation

```yaml
dependencies:
  chatview_connect: <latest-version>
```

## Compatibility with [`chatview_connect`][chatViewConnect]

| `chatview` version | [`chatview_connect`][chatViewConnect] version |
|--------------------|-----------------------------------------------|
| `>=2.4.1 <3.0.0`   | `0.0.1`                                       |
| `>= 3.0.0`         | `0.0.2`                                       |

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
