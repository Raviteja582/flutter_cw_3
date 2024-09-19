import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';

void main() {
  runApp(const PetEmotionApp());
}

class PetEmotionApp extends StatelessWidget {
  const PetEmotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Digital Pet',
      home: PetEmotionScreen(),
    );
  }
}

class PetEmotionScreen extends StatefulWidget {
  const PetEmotionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PetEmotionScreenState createState() => _PetEmotionScreenState();
}

class _PetEmotionScreenState extends State<PetEmotionScreen> {
  String _emotion = 'happy'; // Default emotion
  String _petName = ''; // Pet's custom name
  String _moodText = 'Happy'; // Default mood text
  String _moodEmoji = '😊'; // Default emoji
  int _hungerLevel = 50; // Initial hunger level (0 is not hungry)
  int _happinessLevel = 50; // Initial happiness level
  bool _isNameSet = false; // Tracks if the pet's name is set
  double _opacity = 1.0; // Opacity for animation
  Timer? _hungerTimer; // Timer for automatic hunger increase
  Timer? _happinessCheckTimer; // Timer to check for win condition
  Timer? _gameOverCheckTimer; // Timer to check for loss condition
  final TextEditingController _nameController = TextEditingController();
  bool _isGameOver = false; // Tracks if the game is over
  bool _isGameWon = false; // Tracks if the game is won

  @override
  void initState() {
    super.initState();
    _startHungerTimer(); // Start the hunger timer when the app starts
    _startHappinessCheckTimer(); // Start checking for win condition
    _startGameOverCheckTimer(); // Start checking for game over condition
  }

  @override
  void dispose() {
    _hungerTimer
        ?.cancel(); // Cancel the hunger timer when the widget is disposed
    _happinessCheckTimer?.cancel(); // Cancel the win condition timer
    _gameOverCheckTimer?.cancel(); // Cancel the game over condition timer
    super.dispose();
  }

  // Timer that increases the hunger level every 30 seconds
  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        if (_hungerLevel < 100) {
          _hungerLevel += 10; // Increase hunger level every 30 seconds
          if (_hungerLevel > 100) _hungerLevel = 100;
        }
        _updatePetMood();
      });
    });
  }

  // Timer to check for win condition (happiness above 80 for 3 minutes)
  void _startHappinessCheckTimer() {
    _happinessCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_happinessLevel >= 80) {
        // Start a countdown for win condition (3 minutes)
        Future.delayed(const Duration(minutes: 3), () {
          if (_happinessLevel >= 80) {
            setState(() {
              _isGameWon = true; // Player wins the game
              _endGame();
            });
          }
        });
      }
    });
  }

  // Timer to check for loss condition (hunger 100 and happiness below 10)
  void _startGameOverCheckTimer() {
    _gameOverCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_hungerLevel >= 100 && _happinessLevel <= 10) {
        setState(() {
          _isGameOver = true; // Player loses the game
          _endGame();
        });
      }
    });
  }

  // Method to update pet mood based on hunger level
  void _updatePetMood() {
    setState(() {
      if (_hungerLevel >= 80) {
        _emotion = 'hungry';
        _moodText = 'Hungry';
        _moodEmoji = '🍖';
        _happinessLevel -= 10; // Lower happiness when very hungry
      } else if (_hungerLevel >= 50) {
        _emotion = 'neutral';
        _moodText = 'Neutral';
        _moodEmoji = '😐';
        _happinessLevel = 50;
      } else {
        _emotion = 'happy';
        _moodText = 'Happy';
        _moodEmoji = '😊';
        _happinessLevel = 100;
      }
    });
  }

  // Method to feed the pet and decrease hunger level
  void _feedPet() {
    setState(() {
      if (_hungerLevel > 0) {
        _hungerLevel -= 5; // Decrease hunger level by 20 when feeding
        if (_hungerLevel < 0) _hungerLevel = 0;
      }
      _updatePetMood();
    });
  }

  // Method to update emotion, mood, and trigger animation
  void _updateEmotion(String emotion) {
    setState(() {
      _emotion = emotion;
      _opacity = 0.0; // Fade out first
      switch (emotion) {
        case 'happy':
          _moodText = 'Happy';
          _moodEmoji = '😊';
          break;
        case 'neutral':
          _moodText = 'Neutral';
          _moodEmoji = '😐';
          break;
        case 'sad':
          _moodText = 'Unhappy';
          _moodEmoji = '😢';
          break;
        case 'hungry':
          _moodText = 'Hungry';
          _moodEmoji = '🍖';
          break;
        default:
          _moodText = 'Happy';
          _moodEmoji = '😊';
      }
    });

    // Fade in the new image and mood text
    Future.delayed(const Duration(milliseconds: 30), () {
      setState(() {
        _opacity = 1.0; // Fade in
      });
    });
  }

  String _getEmotionImage() {
    switch (_emotion) {
      case 'happy':
        return 'images/happy.jpg';
      case 'neutral':
        return 'images/neutral.jpg';
      case 'hungry':
        return 'images/hungry.jpg';
      case 'sad':
        return 'images/sad.jpg';
      default:
        return 'images/happy.jpg';
    }
  }

  void _playWithPet() {
    setState(() {
      _happinessLevel = (_happinessLevel + 10).clamp(0, 100);
      _updateHunger();
    });
  }

  void _updateHappiness() {
    if (_hungerLevel < 30) {
      _happinessLevel = (_happinessLevel - 20).clamp(0, 100);
    } else {
      _happinessLevel = (_happinessLevel + 10).clamp(0, 100);
    }
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    _hungerLevel = (_hungerLevel + 5).clamp(0, 100);
    if (_hungerLevel > 100) {
      _hungerLevel = 100;
      _happinessLevel = (_happinessLevel - 20).clamp(0, 100);
    }
  }

  // Method to set the pet's name
  void _setPetName() {
    setState(() {
      _petName = _nameController.text;
      _isNameSet = true; // Pet name is now set
    });
  }

  // Method to end the game (either win or lose)
  void _endGame() {
    _hungerTimer?.cancel();
    _happinessCheckTimer?.cancel();
    _gameOverCheckTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
      ),
      body: _isGameOver
          ? const Center(
              child: Text(
                'Game Over! Your pet is too hungry and unhappy.',
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
            )
          : _isGameWon
              ? const Center(
                  child: Text(
                    'Congratulations! You kept your pet happy for 3 minutes!',
                    style: TextStyle(fontSize: 24, color: Colors.green),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (!_isNameSet) // Show input only if the pet's name isn't set
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Enter your pet\'s name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _setPetName,
                            child: const Text('Set Name'),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Text(
                            'Your pet\'s name is $_petName!',
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            'Mood: $_moodText $_moodEmoji',
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            'Hunger Level: $_hungerLevel',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.red),
                          ),
                          Text(
                            'Happiness Level: $_happinessLevel',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.green),
                          ),
                          const SizedBox(height: 30),
                          // AnimatedOpacity for smooth transition between images
                          AnimatedOpacity(
                            opacity: _opacity,
                            duration: const Duration(milliseconds: 500),
                            child: Image.asset(
                              _getEmotionImage(),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _feedPet,
                            child: const Text('Feed the Pet'),
                          ),
                          const SizedBox(height: 20),
                          // Buttons to manually change the pet's emotion (for demo purposes)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: _playWithPet,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text('Play with Pet'),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
    );
  }
}
