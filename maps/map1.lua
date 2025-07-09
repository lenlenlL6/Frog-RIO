return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 25,
  height = 20,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 9,
  nextobjectid = 50,
  properties = {
    ["background"] = "Brown"
  },
  tilesets = {
    {
      name = "tile1",
      firstgid = 1,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 22,
      image = "../assets/Terrain/Terrain (16x16).png",
      imagewidth = 352,
      imageheight = 176,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 242,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 25,
      height = 20,
      id = 1,
      name = "Tile Layer 1",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112,
        92, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 93,
        113, 36, 37, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 58, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111,
        113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 8, 8, 8, 8, 9, 111,
        113, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 29, 30, 30, 30, 30, 31, 111,
        113, 7, 8, 8, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 29, 30, 30, 30, 30, 31, 111,
        113, 29, 30, 30, 30, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 7, 9, 30, 30, 30, 30, 31, 111,
        113, 36, 37, 30, 30, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 38, 29, 31, 52, 52, 52, 52, 53, 111,
        113, 58, 59, 52, 52, 53, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 1, 2, 2, 2, 2, 2, 2, 115,
        114, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 115, 112, 112, 112, 112, 112, 112, 112
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 3,
      name = "Player",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 13,
          name = "",
          type = "",
          shape = "point",
          x = 41.6667,
          y = 140,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 4,
      name = "Trap",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {}
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 5,
      name = "Fruit",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 29,
          name = "",
          type = "",
          shape = "point",
          x = 304,
          y = 64,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["id"] = "2"
          }
        },
        {
          id = 33,
          name = "",
          type = "",
          shape = "point",
          x = 144,
          y = 256,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["id"] = "1"
          }
        },
        {
          id = 36,
          name = "",
          type = "",
          shape = "point",
          x = 336,
          y = 64,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["id"] = "2"
          }
        },
        {
          id = 37,
          name = "",
          type = "",
          shape = "point",
          x = 304,
          y = 96,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["id"] = "2"
          }
        },
        {
          id = 38,
          name = "",
          type = "",
          shape = "point",
          x = 336,
          y = 96,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["id"] = "2"
          }
        },
        {
          id = 39,
          name = "",
          type = "",
          shape = "point",
          x = 176,
          y = 256,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["id"] = "1"
          }
        },
        {
          id = 40,
          name = "",
          type = "",
          shape = "point",
          x = 208,
          y = 256,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["id"] = "1"
          }
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "Platform",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 2,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 16,
          width = 16,
          height = 304,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "",
          shape = "rectangle",
          x = 384,
          y = 16,
          width = 16,
          height = 288,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 304,
          width = 256,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 240,
          width = 80,
          height = 64,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "",
          type = "",
          shape = "rectangle",
          x = 80,
          y = 224,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 32,
          width = 32,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "",
          type = "",
          shape = "rectangle",
          x = 48,
          y = 32,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 9,
          name = "",
          type = "",
          shape = "rectangle",
          x = 256,
          y = 256,
          width = 16,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 10,
          name = "",
          type = "",
          shape = "rectangle",
          x = 272,
          y = 256,
          width = 16,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 11,
          name = "",
          type = "",
          shape = "rectangle",
          x = 288,
          y = 208,
          width = 96,
          height = 80,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 16,
          width = 368,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 7,
      name = "Enemy",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 49,
          name = "",
          type = "",
          shape = "point",
          x = 187.5,
          y = 235,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["direction"] = -1,
            ["id"] = "4"
          }
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 8,
      name = "Destination",
      class = "",
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 48,
          name = "",
          type = "",
          shape = "point",
          x = 368,
          y = 208,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
