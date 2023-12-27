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

Note that some images appear deleted. There seems to be no way to currently avoid this without adding more complexity as the API hosts many of its images through Tumblr. You'll just have to skip through such an image.

The second text field is only there to meet the requirements of the project on needing multiple distinct text fields. The same applies for the Facebook button. It's only there because one of our group members was a grad student and decided to do OAuth as his additional requirement (this is not from the CatAPI).

## Vote screen
Here you are able to view the 10 recent images you have voted on. When the phone is on portrait you can only view the images you upvoted. In order to view the images you downvoted, you have to change the orientation of the phone to landscape.

As part of the project requirements, the first image (from either the upvote or downvote image array) is cached, the rest are downloaded. Therefore even if the first image was cached and if it were to become the second element later on, it would be downloaded instead.

## Save screen
Here you are able to view the 10 recent images you have saved locally. There is no way to delete them through the app. You have to manually navigate to your user documents folder and delete them through there (or on your phone if you're not running through the simulator).

# Set Up
Simply clone the project and open it in Xcode. You can then run the simulator or launch it on your phone if you wish.

# Screenshots
## Search screen 
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 05 41](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/4dc7013d-4a96-4b79-a8d0-bec958de10d7)
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 07 06](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/4ab86747-9c0f-483d-a4a2-836c2ad46b38)
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 06 42](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/4406acce-f737-4e5f-bb9c-14f810bd35cf)
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 07 44](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/08a60253-ae39-4210-ae25-e0a00243e914)
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 09 44](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/a05ee3a6-c6d9-44da-ad33-95c625ac8c08)

## Vote screen
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 10 22](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/05254d5b-49f9-4c85-98c5-9ba8c1cac59b)
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 10 30](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/5e31e57b-e05c-4257-ae81-8f221c6e48fe)

## Save screen
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 10 09](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/ab8187e9-43a7-4b1b-9fa0-611a4afa9fba)

## Spanish and French
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 12 36](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/dd0af9d1-d7cd-4508-a819-914f335df3c7)
![Simulator Screenshot - iPhone 14 Pro - 2023-12-26 at 19 14 16](https://github.com/jangel01/CPSC-411-CatAPI-iOS-Mobile-App/assets/60250253/4c83dfbe-d256-4658-a66d-5afbdf4346f9)


