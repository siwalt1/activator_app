// convert enum to string and vice versa
class EnumConverter {
  static String enumToString(Enum enumValue) {
    return enumValue.name;
  }

  static Enum enumFromString<T>(String key, List<Enum> values) {
    return values.firstWhere((v) => key == enumToString(v));
  }
}
