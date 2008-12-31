class Settings
  # constant stores paths to submenus
  @@money_unit = 'CZK'

  SUBMENU = { :menu           => "layouts/menu",
              :property       => "nemovitosti/property_menu",
              :renter         => "manage_renter/menu_renter",
              :renters_sub    => "/renters/renter/submenu",
              :renters_main   => "/renters/renter/menu",
              :renters_property => "/renters/renter/property_menu",
              :finances       => "finances/finances_menu" }
  
  DEFAULT_PICS = { :renter            => "icons/male_user_icon.png",
                   :property          => "img_properties/default.jpg",
                   :hide              => "icons/arrow_hide.png",
                   :delete            => "icons/red_cross_small.png",
                   :note              => "icons/note_small.png",
                   :edit              => "icons/pencil_small.png",
                   :add               => "icons/green_plus.png",
                   :ok                => "icons/green_tick_ok.png",
                   :stop              => "icons/stop_small.png",
                   :green_flag        => "icons/green_flag.png",
                   :ajax_line_green   => "ajax_loaders/ajax_green_line.gif",
                   :ajax_line_blue    => "ajax_loaders/ajax_blue_line.gif",
                   :ajax_blue         => "ajax_loaders/ajax_blue.gif",
                   :ajax_grey         => "ajax_loaders/ajax1.gif",
                   :detail            => "icons/detail_small.png"}
  
  
  def self.set_money_unit(unit_symbol)
    @@money_unit = unit_symbol
  end
  
  def self.get_money_unit
    return @@money_unit
  end
end