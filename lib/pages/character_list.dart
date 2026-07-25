import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/character_service.dart';
import 'character_form.dart';

class CharacterList extends StatefulWidget {
  const CharacterList({super.key});

  @override
  State<CharacterList> createState() => _CharacterListState();
}

class _CharacterListState extends State<CharacterList> {
  String _error = '';
  bool _cargando = false;
  List<CharacterModel> _allCharacters = [];
  List<CharacterModel> _filteredCharacters = [];

  String _searchQuery = '';
  String _selectedCrew = 'Todos';

  final List<String> _crews = [
    'Todos',
    'Straw Hat Pirates',
    'Heart Pirates',
    'Red Hair Pirates',
    'Kid Pirates',
    'Otros'
  ];

  final TextEditingController _searchController = TextEditingController();

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      final data = await CharacterService.getAll();
      if (mounted) {
        setState(() {
          _allCharacters = data;
          _filtrarPersonajes();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _filtrarPersonajes() {
    setState(() {
      _filteredCharacters = _allCharacters.where((char) {
        final matchesSearch = char.name
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;

        bool matchesCrew = false;
        if (_selectedCrew == 'Todos') {
          matchesCrew = true;
        } else if (_selectedCrew == 'Otros') {
          matchesCrew = !_crews.contains(char.crew);
        } else {
          matchesCrew = char.crew == _selectedCrew;
        }

        return matchesSearch && matchesCrew;
      }).toList();
      
      // Ordenar por recompensa descendente de forma predeterminada
      _filteredCharacters.sort((a, b) => (b.bounty ?? 0).compareTo(a.bounty ?? 0));
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatBounty(num? bounty) {
    if (bounty == null) return '฿ 0';
    final String str = bounty.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '฿ ${str.replaceAllMapped(reg, (Match m) => '${m[1]},')}';
  }

  Future<void> _abrirFormulario({CharacterModel? character}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CharacterForm(character: character)),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(character == null
              ? '¡Personaje registrado con éxito!'
              : '¡Personaje actualizado con éxito!'),
          backgroundColor: Colors.amber.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _cargarDatos();
    }
  }

  Future<void> _borrar({required CharacterModel character}) async {
    final confirmar = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(
            opacity: anim.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 28),
                  const SizedBox(width: 8),
                  const Text("Retirar Recompensa"),
                ],
              ),
              content: Text(
                "¿Está seguro de eliminar a \"${character.name}\" del cartel de búsqueda del Gobierno Mundial?",
                style: const TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Eliminar"),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmar == true && character.id != null) {
      try {
        setState(() => _cargando = true);
        await CharacterService.delete(character.id!);
        _cargarDatos();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Personaje eliminado con éxito.'),
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _error = e.toString());
        }
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.amber.shade900;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F0), // Tono papel pergamino claro
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723), // Marrón oscuro pirate
        foregroundColor: Colors.amber.shade400,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'GRAND LINE WANTED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.5,
                fontFamily: 'Georgia',
              ),
            ),
            Text(
              'Libro de Recompensas del Gobierno Mundial',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar carteles',
            onPressed: _cargarDatos,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add_moderator),
        label: const Text('Nuevo Cartel', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de búsqueda pirata
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchQuery = value;
                _filtrarPersonajes();
              },
              decoration: InputDecoration(
                hintText: 'Buscar piratas por nombre o rol...',
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _filtrarPersonajes();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
          ),

          // Chips de Tripulaciones
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _crews.length,
              itemBuilder: (context, index) {
                final crew = _crews[index];
                final isSelected = _selectedCrew == crew;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(
                      crew == 'Todos' ? 'Todos' : (crew == 'Otros' ? 'Otros' : crew),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCrew = crew;
                        _filtrarPersonajes();
                      });
                    },
                    selectedColor: const Color(0xFFFFECB3),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : const Color(0xFF4E342E),
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? primaryColor : const Color(0xFFD7CCC8),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de Carteles
          Expanded(
            child: _cargando && _allCharacters.isEmpty
                ? ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => const SkeletonBountyCard(),
                  )
                : _error.isNotEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_very_dissatisfied,
                                    color: primaryColor, size: 64),
                                const SizedBox(height: 16),
                                const Text(
                                  'Error de Red de la Marina',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3E2723),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _cargarDatos,
                                  icon: const Icon(Icons.replay_rounded),
                                  label: const Text('Reintentar conexión'),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarDatos,
                        color: primaryColor,
                        child: _filteredCharacters.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          size: 72, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Ningún Pirata coincide con la búsqueda',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3E2723),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Prueba cambiando de tripulación o texto.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 80, top: 4),
                                itemCount: _filteredCharacters.length,
                                itemBuilder: (context, index) {
                                  final char = _filteredCharacters[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1), // Color pergamino envejecido
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFD7CCC8),
                                        width: 1.5,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Imagen del avatar estilo cartel
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              width: 90,
                                              height: 110,
                                              color: const Color(0xFFEFEBE9),
                                              child: char.avatar != null &&
                                                      char.avatar!.isNotEmpty
                                                  ? Image.network(
                                                      char.avatar!,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child, progress) {
                                                        if (progress == null) {
                                                          return child;
                                                        }
                                                        return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                              error, stackTrace) =>
                                                          Icon(
                                                        Icons.person_pin_rounded,
                                                        size: 48,
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
                                          const SizedBox(width: 16),
                                          // Detalles
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  char.name ?? 'Desconocido',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF3E2723),
                                                    fontFamily: 'Georgia',
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Rol: ${char.role ?? "Pirata"}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF5D4037),
                                                  ),
                                                ),
                                                Text(
                                                  'Fruta: ${char.devilFruit ?? "Ninguna"}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF5D4037),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFECB3),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xFFFFE082)),
                                                  ),
                                                  child: Text(
                                                    char.crew ?? 'Sin Tripulación',
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // Recompensa
                                                Text(
                                                  _formatBounty(char.bounty),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.red.shade900,
                                                    fontFamily: 'monospace',
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Acciones de edicion/borrado
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_note_rounded,
                                                  color: Colors.blueGrey,
                                                  size: 26,
                                                ),
                                                tooltip: 'Editar',
                                                onPressed: () =>
                                                    _abrirFormulario(character: char),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_forever_rounded,
                                                  color: Colors.red.shade800,
                                                  size: 26,
                                                ),
                                                tooltip: 'Eliminar',
                                                onPressed: () =>
                                                    _borrar(character: char),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}

// Skeleton Loader para la carga de Recompensas
class SkeletonBountyCard extends StatefulWidget {
  const SkeletonBountyCard({super.key});

  @override
  State<SkeletonBountyCard> createState() => _SkeletonBountyCardState();
}

class _SkeletonBountyCardState extends State<SkeletonBountyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 0.75).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1).withAlpha(150),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
