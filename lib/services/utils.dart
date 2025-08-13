String capitalizedTitle(String text) {
  const excludedWords = [
    'a',
    'an',
    'and',
    'as',
    'at',
    'but',
    'by',
    'for',
    'in',
    'nor',
    'of',
    'on',
    'or',
    'the',
  ];

  return text
      .split(' ')
      .asMap()
      .map((index, word) {
        if (word.isEmpty) {
          return MapEntry(index, word);
        }
        if (index == 0 ||
            (index > 0 &&
                text.split(' ')[index - 1].toLowerCase() == 'vitamin' &&
                word.toLowerCase() == 'a')) {
          return MapEntry(
              index, word[0].toUpperCase() + word.substring(1).toLowerCase());
        }
        if (excludedWords.contains(word.toLowerCase())) {
          return MapEntry(index, word.toLowerCase());
        }
        return MapEntry(
            index, word[0].toUpperCase() + word.substring(1).toLowerCase());
      })
      .values
      .join(' ');
}