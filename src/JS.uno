using Uno;
using Uno.UX;
using Uno.Platform;
using Uno.Collections;
using Uno.Compiler.ExportTargetInterop;
using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;

namespace Fuse.APNS
{
	/**
		@scriptmodule APNS

		Handles push notification from Apple's Push Notification Service

		@include Docs/Guide.md

		## Remarks

		This module is an @EventEmitter, so the methods from @EventEmitter can be used to listen to events.

		You need to add a project reference to `Fuse.APNS` in your unoproj file to use this feature.
	*/
	[UXGlobalModule]
	public sealed class APNSModule : NativeEventEmitterModule
	{
		static readonly APNSModule _instance;

		public APNSModule()
			: base(true,
				"receivedMessage",
				"registrationSucceeded")
		{
			if (_instance != null) return;
			Resource.SetGlobalKey(_instance = this, "APNS");

			// Old-style events for backwards compatibility
			var onReceivedMessage = new NativeEvent("onReceivedMessage");
			var onRegistrationFailed = new NativeEvent("onRegistrationFailed");
			var onRegistrationSucceeded = new NativeEvent("onRegistrationSucceeded");

			On("receivedMessage", onReceivedMessage);
			// Note: If we decide to remove these old-style events in the future, the
			// "error" event will no longer have a listener by default, meaning that the
			// module will then throw an exception on "error" (as per the way
			// EventEmitter works), unlike the current behaviour.  To retain the current
			// behaviour we might then want to add a dummy listener to the "error"
			// event.
			On("error", onRegistrationFailed);
			On("registrationSucceeded", onRegistrationSucceeded);

			AddMember(onReceivedMessage);
			AddMember(onRegistrationSucceeded);
			AddMember(onRegistrationFailed);
			AddMember(new NativeFunction("clearBadgeNumber", ClearBadgeNumber));
			AddMember(new NativeFunction("clearAllNotifications", ClearAllNotifications));

			Fuse.APNS.APNService.ReceivedNotification += OnReceivedNotification;
			Fuse.APNS.APNService.RegistrationSucceeded += OnRegistrationSucceeded;
			Fuse.APNS.APNService.RegistrationFailed += OnRegistrationFailed;
		}

		/**
			@scriptevent receivedMessage
			@param message The content of the notification as json

			Triggered when your app receives a notification.
		*/
		void OnReceivedNotification(object sender, KeyValuePair<string,bool>message)
		{
			Emit("receivedMessage", message.Key, message.Value);
		}

		/**
			@scriptevent registrationSucceeded
			@param message The registration key from the backend

			Triggered when your app registers with the APNS
		*/
		void OnRegistrationSucceeded(object sender, string message)
		{
			Emit("registrationSucceeded", message);
		}

		/**
			@scriptevent error
			@param message A backend specific reason for the failure.

			Called if your app fails to register with the backend.
		*/
		void OnRegistrationFailed(object sender, string message)
		{
			EmitError(message);
		}

		/**
			@scriptmethod clearBadgeNumber

			Clears the badge number shown on the iOS home screen.
		*/
		public object ClearBadgeNumber(Context context, object[] args)
		{
			Fuse.APNS.APNService.ClearBadgeNumber();
			return null;
		}

		/**
			@scriptmethod clearAllNotifications

			Cancels all previously shown notifications.
		*/
		public object ClearAllNotifications(Context context, object[] args)
		{
			Fuse.APNS.APNService.ClearAllNotifications();
			return null;
		}
	}
}
