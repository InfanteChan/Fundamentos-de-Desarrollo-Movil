import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static const _bucketNombre = 'fotos_lugares';
  final SupabaseClient _db = Supabase.instance.client;

  StorageFileApi get _bucket => _db.storage.from(_bucketNombre);

  /// Sube la foto a la carpeta del usuario y devuelve su URL pública.
  Future<String> subirFoto(XFile foto) async {
    final userId = _db.auth.currentUser!.id;
    final nombre = foto.name.toLowerCase();
    final esPng = nombre.endsWith('.png');
    final ext = esPng ? 'png' : 'jpg';
    final ruta = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    final bytes = await foto.readAsBytes(); // funciona en web y en celular
    await _bucket.uploadBinary(
      ruta,
      bytes,
      fileOptions: FileOptions(contentType: esPng ? 'image/png' : 'image/jpeg'),
    );
    return _bucket.getPublicUrl(ruta);
  }

  /// Borra una foto a partir de su URL pública.
  Future<void> eliminarFoto(String url) async {
    const marcador = '/$_bucketNombre/';
    final i = url.indexOf(marcador);
    if (i == -1) return;
    await _bucket.remove([url.substring(i + marcador.length)]);
  }
}