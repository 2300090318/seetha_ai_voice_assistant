import 'package:contacts_service/contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/permissions.dart';

class SeethaContactsService { // Renamed from ContactsService to avoid conflict with plugin
  Future<Contact?> findContact(String name) async {
    final granted = await AppPermissions.requestContacts();
    if (!granted) return null;

    final contacts = await ContactsService.getContacts(query: name);
    if (contacts.isNotEmpty) {
      return contacts.first;
    }
    return null;
  }

  Future<bool> makeCall(String name) async {
    final contact = await findContact(name);
    if (contact == null || contact.phones == null || contact.phones!.isEmpty) {
      return false;
    }

    final phone = contact.phones!.first.value?.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone == null || phone.isEmpty) return false;

    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      return true;
    }
    return false;
  }

  Future<bool> sendWhatsApp(String name, String message) async {
    final contact = await findContact(name);
    if (contact == null || contact.phones == null || contact.phones!.isEmpty) {
      return false;
    }

    final phone = contact.phones!.first.value?.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone == null || phone.isEmpty) return false;

    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMessage');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      return true;
    }
    return false;
  }
}
