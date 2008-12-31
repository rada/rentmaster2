class Graph
  
  def self.get_settings_from(settings)
    if settings
      return settings
    else
      graph_settings = {}
      graph_settings[:month] = Time.now.mon
      graph_settings[:year] = Time.now.year
      return graph_settings
    end
  end
  
end