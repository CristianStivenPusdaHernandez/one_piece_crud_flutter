import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/character_service.dart';

class CharacterForm extends StatefulWidget {
  final CharacterModel? character;

  const CharacterForm({super.key, this.character});

  @override
  State<CharacterForm> createState() => _CharacterFormState();
}

class _CharacterFormState extends State<CharacterForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();
  final _roleController = TextEditingController();
  final _bountyController = TextEditingController();
  final _devilFruitController = TextEditingController();

  String _selectedCrew = 'Straw Hat Pirates';
  bool _guardando = false;
  String _error = '';

  final List<String> _crews = [
    'Straw Hat Pirates',
    'Heart Pirates',
    'Red Hair Pirates',
    'Kid Pirates',
    'Otros'
  ];

  bool get _esEdicion => widget.character != null;

  @override
  void initState() {
    super.initState();
    
    // Escuchar cambios en la URL del avatar para actualizar la previsualización en tiempo real
    _avatarController.addListener(() {
      setState(() {});
    });

    if (_esEdicion) {
      _nameController.text = widget.character!.name ?? '';
      _avatarController.text = widget.character!.avatar ?? '';
      _roleController.text = widget.character!.role ?? '';
      _bountyController.text = widget.character!.bounty?.toString() ?? '0';
      _devilFruitController.text = widget.character!.devilFruit ?? 'None';
      
      final crewValue = widget.character!.crew ?? 'Straw Hat Pirates';
      if (_crews.contains(crewValue)) {
        _selectedCrew = crewValue;
      } else {
        _selectedCrew = 'Otros';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    _roleController.dispose();
    _bountyController.dispose();
    _devilFruitController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _error = '';
    });

    try {
      final character = CharacterModel(
        id: widget.character?.id,
        name: _nameController.text.trim(),
        avatar: _avatarController.text.trim(),
        crew: _selectedCrew,
        role: _roleController.text.trim(),
        bounty: num.tryParse(_bountyController.text.trim()) ?? 0,
        devilFruit: _devilFruitController.text.trim().isEmpty 
            ? 'None' 
            : _devilFruitController.text.trim(),
      );

      if (_esEdicion) {
        await CharacterService.update(widget.character!.id!, character);
      } else {
        await CharacterService.create(character);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.amber.shade900;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F0), // Papel pergamino
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723), // Marrón pirata
        foregroundColor: Colors.amber.shade400,
        title: Text(
          _esEdicion ? 'Editar Registro' : 'Registrar Recompensa',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
            letterSpacing: 1.0,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Previsualización de Cartel "WANTED"
                  Center(
                    child: Container(
                      width: 150,
                      height: 180,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD7CCC8), width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: double.infinity,
                                  color: const Color(0xFFEFEBE9),
                                  child: _avatarController.text.trim().isNotEmpty
                                      ? Image.network(
                                          _avatarController.text.trim(),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(
                                            Icons.broken_image_rounded,
                                            size: 40,
                                            color: Colors.brown.shade300,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person_pin_rounded,
                                          size: 48,
                                          color: Colors.brown.shade300,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'WANTED',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontFamily: 'Georgia',
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Input Nombre del Pirata
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Pirata',
                      hintText: 'Ej: Monkey D. Luffy',
                      prefixIcon: Icon(Icons.person, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa el nombre del personaje';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input Recompensa (Bounty)
                  TextFormField(
                    controller: _bountyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Recompensa (฿ Berries)',
                      hintText: 'Ej: 3000000000',
                      prefixIcon: Icon(Icons.monetization_on, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa la recompensa';
                      }
                      final bountyVal = num.tryParse(value);
                      if (bountyVal == null) {
                        return 'Por favor ingresa un número válido';
                      }
                      if (bountyVal < 0) {
                        return 'La recompensa no puede ser negativa';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dropdown Tripulación
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCrew,
                    decoration: InputDecoration(
                      labelText: 'Tripulación / Facción',
                      prefixIcon: Icon(Icons.flag_rounded, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    items: _crews.map((crew) {
                      return DropdownMenuItem<String>(
                        value: crew,
                        child: Text(crew),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCrew = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input Rol
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      labelText: 'Rol en la Tripulación',
                      hintText: 'Ej: Espadachín, Navegante, Cocinero',
                      prefixIcon: Icon(Icons.work_rounded, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa el rol del personaje';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input Fruta del Diablo
                  TextFormField(
                    controller: _devilFruitController,
                    decoration: InputDecoration(
                      labelText: 'Fruta del Diablo (Opcional)',
                      hintText: 'Ej: Gomu Gomu no Mi (dejar vacío si es None)',
                      prefixIcon: Icon(Icons.restaurant_menu_rounded, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Input Avatar URL
                  TextFormField(
                    controller: _avatarController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'URL de Imagen de Avatar',
                      hintText: 'Ingresa una URL de imagen válida',
                      prefixIcon: Icon(Icons.image_rounded, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                  ),

                  // Mensaje de Error
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.red.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Botón de Envío
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: _guardando
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _esEdicion ? 'Guardar Cambios' : 'Publicar Cartel',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
