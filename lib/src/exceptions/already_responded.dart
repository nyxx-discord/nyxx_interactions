/// Thrown when you have already responded to an interaction
class AlreadyRespondedError extends Error {
  /// Returns a string representation of this object.
  @override
  String toString() => "AlreadyRespondedError: Interaction has already been acknowledged, you can now only send channel messages (with/without source)";
}
