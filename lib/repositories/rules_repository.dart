class RulesRepository {
  Future<List<String>> getRules() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return [
      "Students must wear the school uniform properly.",
      "Punctuality is mandatory; students must be on time for school.",
      "Respect teachers, staff, and fellow students at all times.",
      "Maintain cleanliness and discipline in classrooms and school premises.",
      "Mobile phones and electronic gadgets are not allowed without permission.",
      "Homework and assignments must be submitted on time.",
      "Bullying, misconduct, and disruptive behavior will not be tolerated.",
      "Students must participate in school activities and events with discipline.",
      "Damaging school property is strictly prohibited.",
      "Follow all safety and emergency procedures as instructed.",
      "Attend all classes and engage actively.",
      "Maintain silence in libraries and study areas.",
      "Adhere to the school's dress code for special events and sports activities.",
      "Show kindness and inclusivity towards peers.",
      "Seek permission before leaving the premises during school hours.",
      "Use school resources responsibly.",
      "Practice good hygiene, including regular handwashing.",
      "Report issues such as bullying, damage, or safety concerns to authorities.",
      "Participate in environmental initiatives like recycling drives.",
      "Foster a culture of learning by helping each other and working collaboratively."
    ];
  }
}
