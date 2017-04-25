## Setting up the client side

### Step 1 (and only).

Include the Fuse push notification library by adding the following to your `.unoproj` file

	"Projects": [
	  "../Fuse.APNS/src/Fuse.APNS.unoproj",
	],

## How this behaves in your app

Referencing `Fuse.PushNotifications` will do the the following:

- When your app starts it registers with APNS. As all access is controlled through Apple's certificate system there is no extra info to provide (we will mention server side a bit later)
- You get a callback telling you if the registration succeeded or failed.
- The succeeded callback will contain your unique registration id (also called a token in iOS docs)
- All future received push notifications will fire a callback containing the JSON of the notification.

All three callbacks mentioned are available in JavaScript and Uno.


## Using the API from JavaScript

Integrating with notifications from JavaScript is simple. Here is an example that just logs when the callbacks fire:

    <JavaScript>
        var push = require("APNS");

        push.on("registrationSucceeded", function(regID) {
            console.log("Reg Succeeded: " + regID);
        });

        push.on("error", function(reason) {
            console.log("Reg Failed: " + reason);
        });

        push.on("receivedMessage", function(payload) {
            console.log("Recieved Push Notification: " + payload);
        });
    </JavaScript>

Here we're using the @EventEmitter `on` method to register our functions with the different events.
In a real app we should send our `registration ID` to our server when `registrationSucceeded` is triggered.

`registrationSucceeded` may be called multiple times during the lifetime of an app as the registration ID may be updated by Apple's backend.

## Server Side

When we have our client all set up and ready to go we move on to the backend. For this we are required to jump through a few hoops.

### Certifying your app for ACS

To do this you need an SSL certificate for your app.

- Go to the [Apple Dev Center](https://developer.apple.com/account/overview.action)
- Go to the Certificates Section for iOS apps
- In the link bar on the left, under the `Identifiers` section click `App IDs`
- Click the `+` icon in the top right to create a new App ID
- Fill in the details, you cant use push notification with a `Wildcard App ID` so pick `Explicit App ID` and check in XCode for the app's `Bundle ID`
- Under `App Services` enable Push notifications (and anything else you need)
- Click `Continue` and confirm the certificate choice you made.

### Syncing XCode

Your app is now authenticated for Push notifications. Be sure to resync your profiles in XCode before re-building your app.
To do this:
- Open XCode
- In the menu-bar choose `XCode`->`Preferences`
- In the Preferences window view the `Accounts` tab
- In the `Accounts` tab click `View Details` for the relevant Apple ID
- Click the small refresh button in the bottom left of the `View Details` window

### Sending Push Notifications to iOS from OSX

For simple testing you may find that setting up a server is a bit of an overkill. To this end we recommend [NWPusher](https://github.com/noodlewerk/NWPusher). Download the binary [here](https://github.com/noodlewerk/NWPusher/releases/tag/0.6.3) and then follow the following sections from the README

- `Getting started`
- `Certificate`
- Instead of reading the `Device Token` section simply add the example from above to your UX file
- Finally, follow the `Push from OS X` Section

Done, you should now be pushing notifications from OSX to iOS.


## The Notification

We support push notifications in JSON format. When a notification arrives one of two things will happen:

- If our app has focus, the callback is called right away with the full JSON payload
- If our app doesn't have focus, (and our JSON contains the correct data) we will add a system notification to the notification bar (called the Notification Center in iOS). When the user clicks the notification in the drop down then our app is launched and the notification is delivered.

In this simple notification message:

    'aps': {
        alert: {
            'title': 'Well would ya look at that!',
            'body': 'Hello from the server'
        }
    },

the 'title' and 'body' will be used as the title and body of the system notification.


## Message size limits

Apple limits the message size to 2048 bytes on iOS 8 and up but only 256 bytes on all earlier versions
