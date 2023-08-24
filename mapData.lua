local mapData = {}

mapData.specs = {
  earth = {
    
    [1] = {
      walls = "normal",
      pegAmount = {2,3},
      lives = 15,
    },
    
    [2] = {
      walls = "normal",
      pegAmount = {3,4,5},
      lives = 15,
    },
    
    [3] = {
      walls = "normal",
      pegAmount = {5,6,7},
      lives = 15,
    },
    
    [4] = {
      walls = "normal",
      pegAmount = {7,8},
      lives = 10,
    },
    
    [5] = {
      walls = "normal",
      pegAmount = {2},
      lives = 15,
    }
    
  },
  
  watalu = {
    
    [1] = {
      walls = "fire",
      pegAmount = {3,4},
      lives = 12,
    },
    
    [2] = {
      walls = "fire",
      pegAmount = {4,5,6},
      lives = 12,
    },
    
    [3] = {
      walls = "fire",
      pegAmount = {6,7,8},
      lives = 12,
    },
    
    [4] = {
      walls = "fire",
      pegAmount = {8,9},
      lives = 8,
    },
    
    [5] = {
      walls = "normal",
      pegAmount = {3},
      lives = 12,
    }
    
  },
  
  epsillion = {
    
    [1] = {
      walls = "portal",
      pegAmount = {3,4,5},
      lives = 10,
    },
    
    [2] = {
      walls = "portal",
      pegAmount = {4,5},
      lives = 10,
    },
    
    [3] = {
      walls = "portal",
      pegAmount = {6,5},
      lives = 10,
    },
    
    [4] = {
      walls = "portal",
      pegAmount = {8},
      lives = 6,
    },
    
    [5] = {
      walls = "portal",
      pegAmount = {3},
      lives = 10,
    }
    
  },
  
  xenova = {
    
    [1] = {
      walls = "normal",
      pegAmount = {4},
      lives = 8,
    },
    
    [2] = {
      walls = "portal",
      pegAmount = {5},
      lives = 8,
    },
    
    [3] = {
      walls = "fire",
      pegAmount = {6},
      lives = 8,
    },
    
    [4] = {
      walls = "portal",
      pegAmount = {8},
      lives = 4,
    },
    
    [5] = {
      walls = "normal",
      pegAmount = {1},
      lives = 8,
    }
    
  },
  
  }

return mapData