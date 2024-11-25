class Globalvariable {
  // Private field
  String hiredagent = '';

  // Private constructor
  Globalvariable._privateConstructor();

  // The single instance of Globalvariable
  static final Globalvariable _instance = Globalvariable._privateConstructor();

  // Getter for agent_id
  String get agent_id => hiredagent;

  // Setter for agent_id
  set agent_id(String id) {
    hiredagent = id;
  }

  // Public factory constructor to access the singleton instance
  factory Globalvariable() {
    return _instance;
  }
}

// ----------------------for chat agent id
class Globalvariableforchat {
  // Private field
  String hiredagent = '';

  // Private constructor
  Globalvariableforchat._privateConstructor();

  // The single instance of Globalvariable
  static final Globalvariableforchat _instance =
      Globalvariableforchat._privateConstructor();

  // Getter for agent_id
  String get agent_id => hiredagent;

  // Setter for agent_id
  set agent_id(String id) {
    hiredagent = id;
  }

  // Public factory constructor to access the singleton instance
  factory Globalvariableforchat() {
    return _instance;
  }
}
