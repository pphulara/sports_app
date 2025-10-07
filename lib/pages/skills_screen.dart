import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Skill {
  final String name;
  final String level;
  final String image;
  final String description;

  Skill({
    required this.name,
    required this.level,
    required this.image,
    required this.description,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] as String,
      level: json['level'] as String,
      image: json['image'] as String,
      description: json['description'] as String? ?? "No description available",
    );
  }
}

class ResponsiveSize {
  static double getWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double getHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  static bool isMobile(BuildContext context) => getWidth(context) < 600;
  static bool isTablet(BuildContext context) => getWidth(context) >= 600 && getWidth(context) < 900;
  static bool isDesktop(BuildContext context) => getWidth(context) >= 900;
  
  static double fontSize(BuildContext context, double size) {
    double width = getWidth(context);
    if (width < 360) return size * 0.85;
    if (width < 600) return size;
    if (width < 900) return size * 1.1;
    return size * 1.2;
  }
  
  static double spacing(BuildContext context, double size) {
    double width = getWidth(context);
    if (width < 360) return size * 0.8;
    if (width < 600) return size;
    if (width < 900) return size * 1.2;
    return size * 1.4;
  }
  
  static double cardWidth(BuildContext context) {
    double width = getWidth(context);
    if (width < 360) return width * 0.65;
    if (width < 600) return width * 0.7;
    if (width < 900) return width * 0.6;
    return width * 0.5;
  }
  
  static double cardHeight(BuildContext context) {
    double width = getWidth(context);
    if (width < 360) return 200;
    if (width < 600) return 240;
    if (width < 900) return 280;
    return 320;
  }
}

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> with TickerProviderStateMixin {
  List<Skill> skills = [];
  Map<String, List<Skill>> groupedSkills = {};
  Map<String, List<Skill>> filteredGroupedSkills = {};
  final List<String> levelOrder = ['Basic', 'Intermediate', 'Advanced'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    loadSkills();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterSkills();
    });
  }

  void _filterSkills() {
    if (_searchQuery.isEmpty) {
      filteredGroupedSkills = Map.from(groupedSkills);
    } else {
      filteredGroupedSkills = {
        'Basic': [],
        'Intermediate': [],
        'Advanced': [],
      };

      groupedSkills.forEach((level, skillsList) {
        filteredGroupedSkills[level] = skillsList
            .where((skill) =>
                skill.name.toLowerCase().contains(_searchQuery) ||
                skill.description.toLowerCase().contains(_searchQuery))
            .toList();
      });
    }
  }

  Future<void> loadSkills() async {
    final String response =
        await rootBundle.loadString('lib/assets/skills.json');
    final List<dynamic> jsonList = json.decode(response);

    skills = jsonList.map((item) => Skill.fromJson(item)).toList();

    groupedSkills = {
      'Basic': [],
      'Intermediate': [],
      'Advanced': [],
    };

    for (var skill in skills) {
      if (groupedSkills.containsKey(skill.level)) {
        groupedSkills[skill.level]!.add(skill);
      }
    }

    filteredGroupedSkills = Map.from(groupedSkills);
    setState(() {});
    _fadeController.forward();
  }

  Color getLevelColor(String level) {
    switch (level) {
      case 'Basic':
        return const Color(0xFF00C853);
      case 'Intermediate':
        return const Color(0xFFFF6D00);
      case 'Advanced':
        return const Color(0xFFD50000);
      default:
        return Colors.grey;
    }
  }

  List<Color> getLevelGradient(String level) {
    switch (level) {
      case 'Basic':
        return [const Color(0xFF00E676), const Color(0xFF00C853)];
      case 'Intermediate':
        return [const Color(0xFFFF9100), const Color(0xFFFF6D00)];
      case 'Advanced':
        return [const Color(0xFFFF1744), const Color(0xFFD50000)];
      default:
        return [Colors.grey, Colors.grey[700]!];
    }
  }

  IconData getLevelIcon(String level) {
    switch (level) {
      case 'Basic':
        return Icons.star_rounded;
      case 'Intermediate':
        return Icons.bolt_rounded;
      case 'Advanced':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.circle;
    }
  }

  void _showSkillDialog(Skill skill, Color levelColor, List<Color> gradient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 24)),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveSize.isMobile(context) ? double.infinity : 500,
              maxHeight: ResponsiveSize.getHeight(context) * 0.7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ResponsiveSize.spacing(context, 24)),
                    topRight: Radius.circular(ResponsiveSize.spacing(context, 24)),
                  ),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: skill.image,
                        height: ResponsiveSize.getHeight(context) * 0.25,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        maxWidthDiskCache: 800,
                        maxHeightDiskCache: 600,
                        placeholder: (context, url) => Container(
                          height: ResponsiveSize.getHeight(context) * 0.25,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: ResponsiveSize.getHeight(context) * 0.25,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient),
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: ResponsiveSize.fontSize(context, 60),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: ResponsiveSize.spacing(context, 12),
                        right: ResponsiveSize.spacing(context, 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.close_rounded, color: levelColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(ResponsiveSize.spacing(context, 24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(ResponsiveSize.spacing(context, 10)),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradient),
                                borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: levelColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                getLevelIcon(skill.level),
                                color: Colors.white,
                                size: ResponsiveSize.fontSize(context, 24),
                              ),
                            ),
                            SizedBox(width: ResponsiveSize.spacing(context, 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    skill.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: ResponsiveSize.fontSize(context, 22),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF212121),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveSize.spacing(context, 10),
                                      vertical: ResponsiveSize.spacing(context, 4),
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: gradient),
                                      borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 8)),
                                    ),
                                    child: Text(
                                      skill.level,
                                      style: GoogleFonts.poppins(
                                        fontSize: ResponsiveSize.fontSize(context, 12),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveSize.spacing(context, 20)),
                        Container(
                          padding: EdgeInsets.all(ResponsiveSize.spacing(context, 16)),
                          decoration: BoxDecoration(
                            color: gradient[0].withOpacity(0.08),
                            borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 16)),
                            border: Border.all(
                              color: gradient[0].withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    color: levelColor,
                                    size: ResponsiveSize.fontSize(context, 20),
                                  ),
                                  SizedBox(width: ResponsiveSize.spacing(context, 8)),
                                  Text(
                                    'Description',
                                    style: GoogleFonts.poppins(
                                      fontSize: ResponsiveSize.fontSize(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: levelColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveSize.spacing(context, 12)),
                              Text(
                                skill.description,
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveSize.fontSize(context, 14),
                                  color: const Color(0xFF424242),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
        ),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: false, 
                  expandedHeight: ResponsiveSize.spacing(context, 190),
                  floating: false,
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: EdgeInsets.fromLTRB(
                        ResponsiveSize.spacing(context, 20),
                        ResponsiveSize.spacing(context, 16),
                        ResponsiveSize.spacing(context, 20),
                        ResponsiveSize.spacing(context, 0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Skill Scroll',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: ResponsiveSize.fontSize(context, 32),
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveSize.spacing(context, 6)),
                                  Text(
                                    'Discover New Skills',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF6B7280),
                                      fontSize: ResponsiveSize.fontSize(context, 14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.all(ResponsiveSize.spacing(context, 12)),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8B5CF6),
                                      Color(0xFF6366F1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 16)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.emoji_events_rounded,
                                  color: Colors.white,
                                  size: ResponsiveSize.fontSize(context, 26),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveSize.spacing(context, 24)),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 16)),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: ResponsiveSize.fontSize(context, 14),
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: Container(
                                  padding: EdgeInsets.all(ResponsiveSize.spacing(context, 12)),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: const Color(0xFF6366F1),
                                    size: ResponsiveSize.fontSize(context, 22),
                                  ),
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.close_rounded,
                                          color: const Color(0xFF6B7280),
                                          size: ResponsiveSize.fontSize(context, 20),
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 16)),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 16)),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 16)),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6366F1),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveSize.spacing(context, 16),
                                  vertical: ResponsiveSize.spacing(context, 14),
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveSize.fontSize(context, 14),
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: EdgeInsets.only(
                  bottom: ResponsiveSize.spacing(context, 16),
                ),
                itemCount: levelOrder.length,
                itemBuilder: (context, index) {
                  final level = levelOrder[index];
                  final levelSkills = filteredGroupedSkills[level] ?? [];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveSize.spacing(context, 32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveSize.spacing(context, 20),
                            vertical: ResponsiveSize.spacing(context, 12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(ResponsiveSize.spacing(context, 10)),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: getLevelGradient(level),
                                  ),
                                  borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 12)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: getLevelColor(level).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  getLevelIcon(level),
                                  color: Colors.white,
                                  size: ResponsiveSize.fontSize(context, 20),
                                ),
                              ),
                              SizedBox(width: ResponsiveSize.spacing(context, 12)),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: getLevelGradient(level),
                                ).createShader(bounds),
                                child: Text(
                                  level,
                                  style: GoogleFonts.poppins(
                                    fontSize: ResponsiveSize.fontSize(context, 24),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: ResponsiveSize.spacing(context, 10)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveSize.spacing(context, 10),
                                  vertical: ResponsiveSize.spacing(context, 5),
                                ),
                                decoration: BoxDecoration(
                                  color: getLevelColor(level).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(ResponsiveSize.spacing(context, 8)),
                                ),
                                child: Text(
                                  '${levelSkills.length}',
                                  style: GoogleFonts.poppins(
                                    fontSize: ResponsiveSize.fontSize(context, 13),
                                    color: getLevelColor(level),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveSize.cardHeight(context) + 40,
                          child: levelSkills.isEmpty
                              ? Center(
                                  child: Text(
                                    _searchQuery.isEmpty
                                        ? 'No skills available'
                                        : 'No matching skills',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: ResponsiveSize.fontSize(context, 14),
                                    ),
                                  ),
                                )
                              : SkillCarousel(
                                  skills: levelSkills,
                                  levelColor: getLevelColor(level),
                                  gradient: getLevelGradient(level),
                                  onTap: (skill) => _showSkillDialog(
                                    skill,
                                    getLevelColor(level),
                                    getLevelGradient(level),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SkillCarousel extends StatefulWidget {
  final List<Skill> skills;
  final Color levelColor;
  final List<Color> gradient;
  final Function(Skill) onTap;

  const SkillCarousel({
    super.key,
    required this.skills,
    required this.levelColor,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<SkillCarousel> createState() => _SkillCarouselState();
}

class _SkillCarouselState extends State<SkillCarousel> {
  late PageController _pageController;
  double _currentPage = 0;
  static const int _initialPage = 10000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: _initialPage,
    );
    _currentPage = _initialPage.toDouble();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? _initialPage.toDouble();
      });
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page ?? _initialPage.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getActualIndex(int virtualIndex) {
    return virtualIndex % widget.skills.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.skills.isEmpty) {
      return Center(
        child: Text(
          'No skills available',
          style: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: ResponsiveSize.fontSize(context, 14),
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, virtualIndex) {
        int actualIndex = _getActualIndex(virtualIndex);
        double difference = (virtualIndex - _currentPage).abs();
        double scale = 1.0 - (difference * 0.15).clamp(0.0, 0.15);
        double opacity = 1.0 - (difference * 0.3).clamp(0.0, 0.3);

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: scale, end: scale),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSize.spacing(context, 8),
                    vertical: ResponsiveSize.spacing(context, 12),
                  ),
                  child: CarouselCard(
                    skill: widget.skills[actualIndex],
                    levelColor: widget.levelColor,
                    gradient: widget.gradient,
                    onTap: () => widget.onTap(widget.skills[actualIndex]),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CarouselCard extends StatefulWidget {
  final Skill skill;
  final Color levelColor;
  final List<Color> gradient;
  final VoidCallback onTap;

  const CarouselCard({
    super.key,
    required this.skill,
    required this.levelColor,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveSize.spacing(context, 24);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 10,
        shadowColor: widget.levelColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) {
            _scaleController.reverse();
            widget.onTap();
          },
          onTapCancel: () => _scaleController.reverse(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.skill.image,
                fit: BoxFit.cover,
                maxWidthDiskCache: 600,
                maxHeightDiskCache: 400,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradient.map((c) => c.withOpacity(0.2)).toList(),
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.levelColor),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradient.map((c) => c.withOpacity(0.3)).toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: ResponsiveSize.fontSize(context, 50),
                        color: Colors.white,
                      ),
                      SizedBox(height: ResponsiveSize.spacing(context, 8)),
                      Text(
                        'Image unavailable',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveSize.fontSize(context, 12),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: [0.3, 0.7, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: ResponsiveSize.spacing(context, 12),
                right: ResponsiveSize.spacing(context, 12),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveSize.spacing(context, 8)),
                  decoration: BoxDecoration(
                    color: widget.levelColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: ResponsiveSize.fontSize(context, 18),
                  ),
                ),
              ),
              Positioned(
                bottom: ResponsiveSize.spacing(context, 16),
                left: ResponsiveSize.spacing(context, 16),
                right: ResponsiveSize.spacing(context, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.skill.name,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveSize.fontSize(context, 18),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveSize.spacing(context, 8)),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.65,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: widget.gradient),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: widget.gradient[0].withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}