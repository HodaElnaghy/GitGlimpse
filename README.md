<table>
  <tr>
    <td><img src="logo.png" alt="GitHub Logo" width="100" /></td>
    <td><h1>GitGlimpse</h1></td>
  </tr>
</table>


GitGlimpse is a mobile app that allows you to explore public GitHub repositories. It provides essential information about repositories, their owners, and supports both light and dark modes. It even checks for internet connectivity to keep you informed. 

I implemented the bonus feature - pagination using Realm for an API that doesn't support it.

## Features

- View and retrieve public GitHub repositories.
- Display repository name, owner's name, and owner's avatar.
- Show the creation date in a user-friendly format.
- Support light and dark mode for your comfort.
- Check for internet connectivity to keep you informed.

## Implementation Highlights

- Utilized Dispatch Group to handle multiple API requests for different repository details.
- Employed Realm for local data persistence to support pagination.
- Leveraged Alamofire for network requests, Kingfisher for image loading, and Reachability to check for internet connectivity.
- Enhanced the UI to provide an engaging user experience.

## UI
<div style="display: inline-block;">
  <img src="noInternet.png" alt="No Internet" width="200" />
  <img src="darkMode.png" alt="Dark Mode" width="210" />
  <img src="lightMode.png" alt="Light Mode" width="205" />
</div>

# Responsive UI
<div style="display: inline-block;">
  <img src="responsive1.png" alt="Responsivity1" width="200" />
  <img src="responsive2.png" alt="Responsivity2" width="210" />
</div>

## Credits

- [Alamofire](https://github.com/Alamofire/Alamofire)
- [Realm](https://realm.io/docs/swift/latest/)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [Reachability](https://github.com/ashleymills/Reachability)

