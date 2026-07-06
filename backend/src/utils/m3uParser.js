/**
 * M3U Playlist Parser
 * Parses M3U/M3U8 text into a structured JSON array of channels.
 */
const parseM3U = (m3uString) => {
  const lines = m3uString.split(/\r?\n/);
  const channels = [];
  let currentChannel = null;

  for (let line of lines) {
    line = line.trim();
    if (line.startsWith("#EXTINF:")) {
      currentChannel = {};

      // Get channel name (everything after the last comma)
      const commaIndex = line.lastIndexOf(",");
      if (commaIndex !== -1) {
        currentChannel.name = line.substring(commaIndex + 1).trim();
      } else {
        currentChannel.name = "Canal Sem Nome";
      }

      // Get tvg-logo
      const logoMatch = line.match(/tvg-logo="([^"]+)"/i);
      currentChannel.logo = logoMatch ? logoMatch[1] : "";

      // Get group-title (category/group)
      const groupMatch = line.match(/group-title="([^"]+)"/i);
      currentChannel.category = groupMatch ? groupMatch[1] : "Geral";
    } else if ((line.startsWith("http://") || line.startsWith("https://")) && currentChannel) {
      currentChannel.url = line;
      channels.push(currentChannel);
      currentChannel = null;
    }
  }
  return channels;
};

module.exports = { parseM3U };
