import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // En Docker: backend se llama 'backend', en desarrollo local: localhost:8000
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8003/api',
  );

  // ─── SUCURSALES ─────────────────────────────────────────────────────────────
  static Future<List<Sucursal>> getSucursales() async {
    final res = await http.get(Uri.parse('$baseUrl/sucursales/'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Sucursal.fromJson(e)).toList();
    }
    throw Exception('Error al cargar sucursales');
  }

  static Future<Sucursal> createSucursal(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/sucursales/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return Sucursal.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Error al crear');
  }

  static Future<Sucursal> updateSucursal(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/sucursales/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return Sucursal.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Error al actualizar');
  }

  static Future<void> deleteSucursal(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/sucursales/$id'));
    if (res.statusCode != 204) throw Exception('Error al eliminar');
  }

  // ─── AUDITORES ──────────────────────────────────────────────────────────────
  static Future<List<Auditor>> getAuditores() async {
    final res = await http.get(Uri.parse('$baseUrl/auditores/'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Auditor.fromJson(e)).toList();
    }
    throw Exception('Error al cargar auditores');
  }

  static Future<Auditor> createAuditor(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auditores/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return Auditor.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Error al crear');
  }

  static Future<Auditor> updateAuditor(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/auditores/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return Auditor.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Error al actualizar');
  }

  static Future<void> deleteAuditor(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/auditores/$id'));
    if (res.statusCode != 204) throw Exception('Error al eliminar');
  }

  // ─── AUDITORIAS ─────────────────────────────────────────────────────────────
  static Future<List<Auditoria>> getAuditorias() async {
    final res = await http.get(Uri.parse('$baseUrl/auditorias/'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Auditoria.fromJson(e)).toList();
    }
    throw Exception('Error al cargar auditorías');
  }

  static Future<Auditoria> createAuditoria(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auditorias/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return Auditoria.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Error al crear');
  }

  static Future<Auditoria> updateAuditoria(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/auditorias/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return Auditoria.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Error al actualizar');
  }

  static Future<void> deleteAuditoria(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/auditorias/$id'));
    if (res.statusCode != 204) throw Exception('Error al eliminar');
  }

  // ─── USUARIOS ───────────────────────────────────────────────────────────────
  static Future<List<Usuario>> getUsuarios() async {
    final res = await http.get(Uri.parse('$baseUrl/usuarios/'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Usuario.fromJson(e)).toList();
    }
    throw Exception('Error al cargar usuarios');
  }

  static Future<Usuario> createUsuario(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/usuarios/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return Usuario.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Error al crear');
  }

  static Future<Usuario> updateUsuario(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/usuarios/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return Usuario.fromJson(jsonDecode(res.body));
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Error al actualizar');
  }

  static Future<void> deleteUsuario(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/usuarios/$id'));
    if (res.statusCode != 204) throw Exception('Error al eliminar');
  }
}
