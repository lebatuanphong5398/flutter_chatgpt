# GPT-3.5 Powered Chatbox with Flutter

![Chatbox GPT-3.5](screenshot.png)

Welcome to the GPT-3.5 Powered Chatbox project! This Flutter application leverages the power of OpenAI's GPT-3 API to create a chatbot that engages in natural language conversations. Users can also create images, generate summaries, view conversation history, and enjoy real-time interactions.

## Features

- **Natural Language Chat:** Engage in fluid conversations with the GPT-3 powered chatbot.
- **Image Generation:** Command the chatbot to create images based on textual descriptions.
- **Conversation Summaries:** Generate summaries of long conversations to capture key points.
- **Chat History:** Maintain a history of conversations for reference and review.
- **Firebase Integration:** Store chat histories and summaries in Firebase Firestore for seamless synchronization.
- **State Management:** Utilize the Provider package for efficient state management.

## Getting Started

To experience the power of the GPT-3.5 Chatbox on your local machine, follow these steps:

1. Clone this repository: `https://github.com/lebatuanphong5398/flutter_chatgpt.git`
2. Navigate to the project directory: `cd flutter_chatgpt`
3. Install dependencies: `flutter pub get`
4. Set up Firebase:
   - I have dedicated a separate section below for detailed instructions.
5. Run the app: `flutter run`

## Screenshots

![Chat Screen](screenshots/chat_screen.png)
![Image Generation](screenshots/image_generation.png)
![Chat History](screenshots/chat_history.png)

## Technologies Used

- Flutter: A versatile UI toolkit for crafting natively compiled applications.
- OpenAI GPT-3.5 API: Powering the natural language interactions within the chatbox.
- Firebase: Providing backend services including authentication and Firestore database.
- Provider: A recommended state management solution for Flutter apps.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests to help improve the project.

## License

This project is licensed under the [MIT License](LICENSE).


## Setting up Firebase

This chatbox project integrates with Firebase for real-time chat history and summaries. Here's how to set up Firebase for your project:

After downloading this repository, you need to configure Firebase to save your data. Follow these steps:


### Configuring Firebase

To set up Firebase for your project, you'll need the Firebase CLI. Here's how to install and use it:
1. If you haven't already, [install the Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli).
2. Log into Firebase using your Google account by running the following command:
   `firebase login`
3. Install the FlutterFire CLI by running the following command from any directory:
   ```dart pub global activate flutterfire_cli```

### Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click on the "Add project" button.
3. Follow the prompts to set up your project, giving it a name and selecting your preferred analytics settings.
4. 

### Step 2: Add Your App to Firebase

1. After creating the project, click on the "Add app" button (the Android or iOS icon).
2. Follow the instructions to add your Flutter app to the project:
   - For Android:
     - Provide the package name (usually something like `com.example.gpt3_flutter_chatbox`).
     - Download the `google-services.json` configuration file.
     - Place the `google-services.json` file in the `android/app` directory of your project.
   - For iOS:
     - Provide the bundle ID.
     - Download the `GoogleService-Info.plist` configuration file.
     - Add the downloaded file to the `ios/Runner` directory of your project.

### Step 3: Enable Firebase Services

1. In the Firebase Console, navigate to the "Develop" section.
2. Enable the services you need for your project. For this project, you'll need:
   - **Authentication:** Set up authentication methods for user login and registration.
   - **Firestore:** This will be used to store chat histories and summaries.

### Step 4: Initialize Firebase in Your App

1. In your Flutter project, open the `pubspec.yaml` file.
2. Add the `firebase_core` and `cloud_firestore` packages to your dependencies.
3. Run `flutter pub get` to install the packages.
4. Import the Firebase packages in your Dart code and initialize Firebase in your `main.dart`:



Experience the future of chatbots with GPT-3.5 and Flutter!
