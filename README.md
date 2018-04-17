# Virtual Tourist

The Virtual Tourist app allows users to view Flickr photos taken in a geographical locations. Users can drop pins on a map and then view lists of photos taken in that area.

## Features

1. Pin Drop
   * Users press and hold to drop a pin on the map.

2. Picture Collection
   * Users tap on the pin to show a collection of pictures from Flickr for that geographic area

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What things you need to install the software and how to install them

```
- XCode 9.2
- Swift 3.0 or 4.0
```

### Installing

Clone from Github

```
git clone https://github.com/mdtaps/VirtualTourist
```

Get an API Key from Flickr here: https://www.flickr.com/services/apps/create/apply

Create a file in your project named `APIKeyPropertyList.plist` and add a key/value pair to the list.
	* Under "key", put the String `FlickrAPIKey`
	* Under "value", put the API key you got from Flickr


## Built With

* [Flickr API](https://www.flickr.com/services/api/) - Used to pull in user photos

## Authors

* **Mark Tapia** - *Initial work* - [MDTaps](https://github.com/mdtaps)

If you would like to contribute to this project, please leave me a note!

## License

The contents of this repository is licensed under the [MIT License](https://opensource.org/licenses/MIT) 

## Acknowledgments

* Thanks to my beautiful wife who put up with me staying up late many nights and waking her up when I come to bed.
* Udacity Portfolio App
