const axios = require("axios");
const { parseM3U } = require("../utils/m3uParser");

class IptvController {
  async getCanais(req, res) {
    try {
      // req.provedor is populated by tenantMiddleware
      const provedor = req.provedor;
      const m3uUrl = provedor?.m3uUrl;

      if (!m3uUrl) {
        // Return a fallback of public/legal streams for demo purposes
        return res.json({
          channels: [
            {
              name: "TV Brasil Live",
              logo: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_TV_Brasil.png/320px-Logo_TV_Brasil.png",
              category: "Canais Abertos",
              url: "https://ebctv.media.ebc.com.br/hls/tvbrasil/index.m3u8"
            },
            {
              name: "Rede CNT",
              logo: "https://upload.wikimedia.org/wikipedia/pt/4/4e/Logomarca_da_Rede_CNT.png",
              category: "Canais Abertos",
              url: "https://cnt.stream.ciclano.io:1936/live/cnt/playlist.m3u8"
            }
          ]
        });
      }

      // Fetch M3U playlist from URL
      const response = await axios.get(m3uUrl, { timeout: 8000 });
      const channels = parseM3U(response.data);

      res.json({ channels });
    } catch (err) {
      console.error("Erro ao buscar ou processar lista M3U:", err);
      // Fallback response so the app has something to show in dev
      res.json({
        channels: [
          {
            name: "TV Brasil Live",
            logo: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Logo_TV_Brasil.png/320px-Logo_TV_Brasil.png",
            category: "Canais Abertos",
            url: "https://ebctv.media.ebc.com.br/hls/tvbrasil/index.m3u8"
          }
        ]
      });
    }
  }
}

module.exports = new IptvController();
