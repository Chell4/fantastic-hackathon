class Validation {
  Validation._();

  static String? requiredLogin(String? input) {
      if (input == null || input.isEmpty) return "This field cannot be empty";
      if (input.length < 5) return "Login is too short. Must contain at least five characters";
      final RegExp regEx = RegExp(r'^[a-zA-Z0-9_\-]{5,}$');
      if (!regEx.hasMatch(input)) {
        return "Login must meet the criteria. Use only: a-z A-Z 0-9 _ -";
      }
      return null;
  }
}