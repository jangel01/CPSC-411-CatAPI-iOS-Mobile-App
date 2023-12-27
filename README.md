CPSC 411 - Mobile Device Application Programming

This project utilizes the "CatAPI" which can be found here: https://thecatapi.com/

# Group Members

* Mark Raden 
* Jason Angel 
* Jiajun Gu 
* Wesley Zoroya 
* Jesse Shaihor 

# Overview
This project aims to bring some of the functionality of the CatAPI as a mobile application. You are able to fetch random cat images, vote on them, and save them locally on your phone. There are three screens for the app: the search screen, vote screen, and save screen.

## Search screen
Here you are able to view random cat images. You can traverse the images and vote on them. There are only 10 total images per API call. You have to click the reroll button if you want new images. You can also save the image and have it stored locally on your phone (both text fields are required). You can vote or save the same image as many times as you want, there are no restrictions.

Note that some images appear deleted. There seems to be no way to currently avoid this without adding more complexity. The API hosts many of its images through Tumblr. You'll just have to skip through such image.

The second text field is only there to meet the requirements of the project on needing multiple distinct text fields. The same applies for the Facebook button. It's only there because one of ourp group memebers was a grad student and decided to do OAuth as his additional requirement (this is not from the CatAPI).
