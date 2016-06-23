---
layout: post
title: "iOS Data Security"
date: 2013-05-22 13:56
comments: false
categories: iOS
---

On a recent client project we had the need to research the encryption/security features available to iOS applications. This is a modified write-up of our findings. Special thanks to Jay Zeschin [@jayzes](https://twitter.com/jayzes) at [Mode Set](http://modeset.com/) for editing the original draft I wrote. 

There are several layers of security that affect a user’s data when using an iOS app - security at rest on the server, security in transit over the network, and security on the iOS device. Focusing on the iOS device only for now, there are several scenarios that are of primary concern: while a user is actively using the app, while a user not actively using the app, when data is stored on disk, and when data is present in memory (RAM). In addition, there are security concerns inherent in ancillary processes such as backing up a device (via iTunes or iCloud) or migrating data to separate devices (e.g. when a user gets a new phone).

While it is impossible to protect user data 100% in all scenarios, there are a number of options available that provide increasing levels of security and protection. Each additional measure of security has advantages and drawbacks, and comes with some measure of added time and effort during the development process.

###1. Built-in Data Protection

Starting with iOS 4, Apple added operating-system level data security provisions and made them available to app developers. In short, if an app developer chooses to make use of these protections and an app user enables a passcode on their device, all data stored to the device by that app is transparently encrypted and protected from unauthorized access by anyone (including the user) when the device is locked, protecting it while at rest. Technically, this is implemented with a tiered system of encrypted keys called keybags, the last of which is based directly off the user’s passcode. When the passcode is entered and the phone is unlocked, all application data is available and unencrypted.

This built-in protection scheme is what Apple makes use of internally for their own apps (such as Mail). It’s a great option and requires very little development time to integrate, so we strongly recommend using it. Any strategy we choose should, at minimum, include this security measure.

####Pros: 
+	Hardware-keyed and transparent encryption of user data
+	Follows industry standard practices
+	Integrated at the operating-system level
+	Architected, developed and supported by Apple

####Cons: 
+	Requires the user to have a passcode enabled on their device to offer any sort of data protection value
+	Apps are unable to programmatically ascertain whether a user has enabled a device passcode (a relatively recent change), which prevents apps from being able to prompt users or limit functionality to guarantee that data is protected. See more about this in the “Recommendations” section below.

###2. Adding a Second Level of Protection

The two cons of built-in data protection are significant limitations, and due to the low level integration of those built-in protections into the operating system, it is difficult if not impossible to augment them directly. For that reason, it is often necessary to implement additional protection of sensitive data at a higher level. Several industry tested code libraries exist for this purpose, most notably [SQLCipher](http://sqlcipher.net/). These libraries encrypt the data contained in the database files before they are written to disk, in contrast to Apple’s approach of encrypting the file itself.

####Pros: 
+	Offers additional protection on top of Apple’s basic security
+	Data is encrypted and secure even when the device does not have a passcode
+	Ability to customize/control protection and related user interactions within the app

####Cons: 
+	Time consuming to implement, requiring structural changes to the existing data model
+	Requires introducing a strategy for encryption key management 
+	Introduces an overhead for management/maintenance on future feature work

###3. Removing Sensitive Data From Memory

When data is actively in-use by an application it is stored in RAM, a volatile physical location on the device. Depending on the specific use case, some kinds of data are created, accessed, and destroyed all solely in RAM. Other data (downloaded images or data from a local database, for example) is read from disk and stored in RAM. Data stored in this way is necessarily unencrypted and inherently temporary - it is created by the device as needed and discarded when the app is no longer running. However, the way that Apple has architected iOS means that applications may continue to run and be resident in memory when they are in the background, sometimes for days or weeks on end. While it would take a much more concentrated hacking effort, it is technically possible to access data belonging to a running app from memory. Securing this data requires purging all sensitive data from memory when a screen is hidden or the application goes into the background - a process that involves a very careful line-by-line audit of an app and how data is created and stored.


####Pros: 

+	Combined with the previous steps, this is the most secure form of data protection
+ It is much more difficult to exploit a running application with this level of protection

####Cons: 
+	Extremely time consuming to implement
+	Requires close scrutiny of every line of code in the app