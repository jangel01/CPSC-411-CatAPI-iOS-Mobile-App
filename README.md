CPSC 411 - Mobile Device Application Programming

This project utilizes the "CatAPI" which can be found here: https://thecatapi.com/

# Group Members

* Mark Raden 
* Jason Angel 
* Jiajun Gu 
* Wesley Zoroya 
* Jesse Shaihor 

# Overview
This project aims to bring some of the functionality of the CatAPI as a mobile application. You are able to fetch random cat images and vote on them. Additionally, as part of the project requirements, you are able to save the images locally. There are three screens for the app: the search screen, vote screen, and save screen. The app is translated for both Spanish and French.

## Search screen
Here you are able to view random cat images. You can traverse the images and vote on them. There are 10 total images per API call. You have to click the reroll button if you want new images. You can also save the image and have it stored locally on your phone (both text fields are required). You can vote or save the same image as many times as you want, there are no restrictions. Although you do have to navigate back and forth in order to do so.

Note that some images appear deleted. There seems to be no way to currently avoid this without adding more complexity. The API hosts many of its images through Tumblr. You'll just have to skip through such an image.

The second text field is only there to meet the requirements of the project on needing multiple distinct text fields. The same applies for the Facebook button. It's only there because one of our group members was a grad student and decided to do OAuth as his additional requirement (this is not from the CatAPI).

## Vote screen
Here you are able to view the 10 recent images you have voted on. When the phone is on portrait you can only view the images you upvoted. In order to view the images you downvoted, you have to change the orientation of the phone to landscape.

As part of the project requirements, the first image (from either the upvote or downvote image array) is cached, the rest are downloaded. Therefore even if the first image was cached and if it were to become the second element later on, it would be downloaded instead.

## Save screen
Here you are able to view the 10 recent images you have saved locally. There is no way to delete them through the app. You have to manually navigate to your user documents folder and delete them through there (or on your phone if you're not running through the simulator).

# Set Up
Simply clone the project and open it in Xcode. You can then run the simulator or launch it on your phone if you wish.

# Screenshots

