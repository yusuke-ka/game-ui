<template>
  <div class="cards-container" name="card-list">
    <div v-for="(thrownCards, index) in thrownCardsList" :key="index" class="thrown-cards-list">
      <div v-for="card in thrownCards" :key="card.localId" class="thrown-cards" :style="styles()">
        <img :src="'/img/' + card.id + '.png'" class="card-image" />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";

interface Card {
  id: string;
  localId: number;
}

@Component
export default class ThrownCard extends Vue {
  private gameId: number | null = null;
  private userId: number | null = null;
  public thrownCardsList: Card[][] = [];
  private options = {
    animation: 200,
  };
  private server = process.env.VUE_APP_SERVER;
  private webSocket = new WebSocket("ws://" + this.server + ":3000/game");

  public mounted() {
    this.webSocket.onopen = () => {
      // do nothing.
    };

    // websocketでメッセージを受信した時
    this.webSocket.onmessage = (event) => {
      console.log("### websocket.onmessage()");

      // 戻り値チェック
      if (event && event.data) {
        console.log(event.data);
        const json = JSON.parse(event.data);
        if (json.method === "thrown") {
          this.thrownCardsList.push(json.cards);
        }
      }
    };

    // websocketでエラーが発生した時
    this.webSocket.onerror = (event) => {
      console.log("onerror");
      console.log("### websocket.onerror()");
      console.log(event);
    };

    // websocketをクローズした時
    this.webSocket.onclose = (event) => {
      console.log("onclose");
      console.log("### websocket.onclose()");
      console.log(event);
    };
  }

  public init(gameId: number, userId: number) {
    this.thrownCardsList = [];
    this.userId = userId;
    this.gameId = gameId;
    this.sendClientInfo();
  }

  public sendClientInfo() {
    const json = {
      method: "client",
      gameId: this.gameId,
      userId: this.userId,
    };
    if (this.webSocket.readyState == 1) {
      this.webSocket.send(JSON.stringify(json));
    }
  }

  public styles() {
    const deg = Math.floor(Math.random() * 720) - 360;
    return {
      transform: "rotate(" + deg + "deg)",
    };
  }
}
</script>

<style scoped>
.cards-container {
  display: flex;
  justify-content: space-evenly;
  position: relative;
}
.thrown-cards-list {
  display: flex;
  justify-content: center;
  position: absolute;
}
.thrown-cards {
  position: relative;
}
.card-image {
  width: 80px;
}
.card-list-leave-active,
.card-list-enter-active {
  transition: opacity 0.5s, transform 0.5s ease;
}
.card-list-leave-to,
.card-list-enter {
  opacity: 0;
  transform: translateY(-100px);
}
.card-list-leave,
.card-list-enter-to {
  opacity: 1;
}
.card-list-move {
  transition: transform 0.5s;
}
.user-name {
  margin-bottom: 10px;
  font-size: 40px;
  color: #0f0f0f;
  text-shadow: 2px 2px #fff, 5px 5px rgba(204, 183, 193, 0.4);
}
.back-name {
  margin-top: 10px;
  font-size: 20px;
  color: #0f0f0f;
  text-shadow: 2px 2px #fff, 5px 5px rgba(199, 204, 183, 0.4);
}
</style>
