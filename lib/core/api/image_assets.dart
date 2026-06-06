import 'dart:math';

/// 素材管理器 —— 从各分类目录随机取图
class ImageAssets {
  static final _random = Random();

  static const _avatars = <String>[
    'assets/images/rem_wallpapers/01_avatars/safe_2778919.jpg',
    'assets/images/rem_wallpapers/01_avatars/safe_3010228.jpg',
    'assets/images/rem_wallpapers/01_avatars/safe_3016771.jpg',
    'assets/images/rem_wallpapers/01_avatars/safe_3346260.jpg',
    'assets/images/rem_wallpapers/01_avatars/safe_6787918.jpg',
    'assets/images/rem_wallpapers/01_avatars/wallhaven_vmpvzl.image_jpeg.jpg',
  ];

  static const _splash = <String>[
    'assets/images/rem_wallpapers/02_splash/safe_3353093.jpg',
    'assets/images/rem_wallpapers/02_splash/safe_4259306.jpg',
    'assets/images/rem_wallpapers/02_splash/safe_4259318.jpg',
    'assets/images/rem_wallpapers/02_splash/safe_4286955.jpg',
    'assets/images/rem_wallpapers/02_splash/safe_4313184.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_5wzop9.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_6kkvl7.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_83rqjk.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_8o63q1.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_e7erww.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_e7vvwr.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_k7kr26.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_lm2z6l.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_mdqer8.image_png.jpg',
    'assets/images/rem_wallpapers/02_splash/wallhaven_x83lr3.image_png.jpg',
  ];

  static const _welcome = <String>[
    'assets/images/rem_wallpapers/03_welcome/safe_2775615.jpg',
    'assets/images/rem_wallpapers/03_welcome/safe_3024235.jpg',
    'assets/images/rem_wallpapers/03_welcome/safe_3337779.jpg',
    'assets/images/rem_wallpapers/03_welcome/safe_3343403.jpg',
    'assets/images/rem_wallpapers/03_welcome/safe_3351514.jpg',
    'assets/images/rem_wallpapers/03_welcome/safe_4306242.jpg',
    'assets/images/rem_wallpapers/03_welcome/safe_6803790.jpg',
    'assets/images/rem_wallpapers/03_welcome/wallhaven_1kw3yw.image_png.jpg',
    'assets/images/rem_wallpapers/03_welcome/wallhaven_6kd8gq.image_jpeg.jpg',
    'assets/images/rem_wallpapers/03_welcome/wallhaven_72o359.image_jpeg.jpg',
    'assets/images/rem_wallpapers/03_welcome/wallhaven_g77qel.image_png.jpg',
    'assets/images/rem_wallpapers/03_welcome/wallhaven_l3mevr.image_png.jpg',
    'assets/images/rem_wallpapers/03_welcome/wallhaven_lmgxry.image_png.jpg',
    'assets/images/rem_wallpapers/03_welcome/wallhaven_rd52pj.image_jpeg.jpg',
    'assets/images/rem_wallpapers/03_welcome/wallhaven_zx6zlj.image_png.jpg',
  ];

  static const _banner = <String>[
    'assets/images/rem_wallpapers/04_drawer/04a_banner/safe_3007267.jpg',
    'assets/images/rem_wallpapers/04_drawer/04a_banner/safe_6828098.jpg',
    'assets/images/rem_wallpapers/04_drawer/04a_banner/wallhaven_3krr86.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04a_banner/wallhaven_85gxk1.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04a_banner/wallhaven_gjm75d.image_jpeg.jpg',
    'assets/images/rem_wallpapers/04_drawer/04a_banner/wallhaven_vmyr3m.image_jpeg.jpg',
  ];

  static const _wide = <String>[
    'assets/images/rem_wallpapers/04_drawer/04b_wide/kona_373856.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/kona_375998.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven-966y6x.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_39dqly.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_3qreqy.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_72jo9y.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_733yjo.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_dgkpv3.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_g79lod.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_j5vwgm.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_ml2191.image_jpeg.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_y887qx.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_zm5w9o.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_zmexoo.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04b_wide/wallhaven_zp5zpv.image_png.jpg',
  ];

  static const _standard = <String>[
    'assets/images/rem_wallpapers/04_drawer/04c_standard/kona_317861.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/kona_319791.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/kona_377553.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/kona_378395.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/kona_397133.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/safe_3352946.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/safe_6784514.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/wallhaven_3k6w76.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/wallhaven_5wdeo8.image_jpeg.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/wallhaven_9592ed.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/wallhaven_dgzr5o.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/wallhaven_l3d8z2.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/wallhaven_lmgwrp.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/wallhaven_p2wld3.image_png.jpg',
    'assets/images/rem_wallpapers/04_drawer/04c_standard/wallhaven_wqvydx.image_png.jpg',
  ];

  static String? _pick(List<String> pool) {
    if (pool.isEmpty) return null;
    return pool[_random.nextInt(pool.length)];
  }

  static String? get randomAvatar => _pick(_avatars);
  static String? get randomSplash => _pick(_splash);
  static String? get randomWelcome => _pick(_welcome);
  static String? get randomBanner => _pick(_banner);
  static String? get randomDrawerWide => _pick(_wide);
  static String? get randomDrawerStandard => _pick(_standard);

  static Map<String, int> get stats => {
    'avatars': _avatars.length,
    'splash': _splash.length,
    'welcome': _welcome.length,
    'banner': _banner.length,
    'wide': _wide.length,
    'standard': _standard.length,
  };
}
