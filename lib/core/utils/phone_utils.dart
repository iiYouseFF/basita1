String normalizeEgyptPhone(String input) {
  String phone = input.trim();

  if (phone.startsWith('+')) {
    return phone;
  }

  phone = phone.replaceAll(RegExp(r'[^\d]'), '');

  if (phone.startsWith('00')) {
    phone = phone.substring(2);
  }

  if (phone.startsWith('0')) {
    phone = phone.substring(1);
  }

  if (!phone.startsWith('20')) {
    phone = '20$phone';
  }

  return '+$phone';
}