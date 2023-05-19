--  ___         _    ___  _____   __
-- / __| ___ __| |_ |   \| __\ \ / /
-- \__ \/ -_|_-< ' \| |) | _| \ V / 
-- |___/\___/__/_||_|___/|___| \_/  

-- Code by sesh#5567
-- https://github.com/seshborges
-- any problem just call me :)
                                 
config = {

  ["bind para comprar algo"] = 'e',
  ["ativar roubos"] = true,
  ["acl que irá receber o chamado de roubo"] = {
    "Policia",
    "Policia Militar"
  },
  ["delay para realizar outro assalto"] = 120000,
  messages = {
    ["comprar algo no ped"] = "#242424Pressione #ff0000'E' #242424para comprar algo"
  },
  ["tempo para assaltar uma loja"] = 40000,

  estiloDoTexto = {
    text = "Passive Mode",
    font = "default-bold",
    allow = true,
    colorR = 255,
    colorG = 255,
    colorB = 255,
    alpha = 150,
    size = 1.2,
    height = 1,
    distance = 50
  },

  marker = {
    ["tipo de marcador"] = "cylinder",
    ["tamanho do marcador"] = 1.2,
    ["opacidade do marcador"] = 140,
  },

  shops = {
    [1] = { 
      ["retorno financeiro"] = { 2000 },
      ["skin do atendente"] = 167,
      ["menu ao clicar na loja"] = 
        function() 
          exports["Notice"]:addNotification("Abriu o menu", 'success');
        end
      ,
      ["ação quando alguem realizar um assalto"] = 
        function() 
          exports["Notice"]:addNotification("A Policia foi alertada", 'warning')
          callPolice()
        end
      ,
      ["aviso para policia"] = true,
      ["mensagem quando o jogador tentar entrar na loja e ela foi assaltada"] = "Esta loja está fechada. Foi assaltada recentemente.",
      shopId = 1,
      blipIconId = 17,
      ped = { 368.08545, -4.49, 1001.85, 178.03, 9 },
      secondPed = { 370.28171, -3.96829, 1001.85889 },
      markEnter = { 2420.4567871094,-1508.8905029297, 24 },
      markLeave = { 364.90844726563, -11.365772247314, 1001.85156 },
      teleportLeave = { 2422.0327148438+0.5, -1508.6689453125, 23.992208480835, 271.12753295898 },
      robbery = false,
    },
    [2] = { 
      ["retorno financeiro"] = { 2000 },
      ["skin do atendente"] = 205,
      ["menu ao clicar na loja"] = 
        function() 
          exports["Notice"]:addNotification("Abriu o menu", 'success');
        end
      ,
      ["ação quando alguem realizar um assalto"] = 
        function() 
          exports["Notice"]:addNotification("A Policia foi alertada", 'warning')
          callPolice()
        end
      ,
      ["aviso para policia"] = true,
      ["mensagem quando o jogador tentar entrar na loja e ela foi assaltada"] = "Esta loja está fechada. Foi assaltada recentemente.",
      shopId = 2,
      blipIconId = 17,
      ped = { 376.59521, -65.84937, 1001.50781, 178.03, 10 },
      secondPed = {378.65158, -64.47591, 1001.50781},
      markEnter = {1199.24988, -918.14301, 43.12326},
      markLeave = {362.89069, -75.18849, 1001.50781},
      teleportLeave = { 1199.51318, -919.87592, 43.10842, 271.12753295898 },
      robbery = false,
    },
  },

}