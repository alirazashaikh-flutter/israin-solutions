let io = null;

function setSocketIO(socketIO) {
  io = socketIO;
}

function getSocketIO() {
  return io;
}

module.exports = { setSocketIO, getSocketIO };
