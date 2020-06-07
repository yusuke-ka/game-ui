<template>
  <div>
    <span v-if="clientId == 0 && clientRank > 0" class="main-win">{{ clientRank }}位</span>
    <span v-if="clientId == 0" class="user-name">{{ userName }}</span>
    <draggable v-model="cardList" animation="200" :disabled="clientId != 0" @sort="sort()">
      <transition-group class="cards-container" name="card-list">
        <div v-for="card in cardList" :key="card.localId" @click="pickup(card)">
          <img
            :src="'/img/' + card.id + '.png'"
            :class="[
              { emphasis: isTarget },
              clientId == 0 ? 'card-image' : 'back-image',
            ]"
          />
        </div>
      </transition-group>
    </draggable>
    <span v-if="clientId != 0 && clientRank > 0" class="other-win">{{ clientRank }}位</span>
    <span v-if="clientId != 0" class="back-name">{{ userName }}</span>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from "vue-property-decorator";
import draggable from "vuedraggable";

interface Card {
  id: string;
  localId: number;
}

@Component({
  components: { draggable },
})
export default class CardList extends Vue {
  @Prop()
  private clientId!: number;
  private gameId: number | null = null;
  private userId: number | null = null;
  private userName = "";
  private isTarget = false;
  public clientRank = 0;
  public cardList: Card[] = [];
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
        const json = JSON.parse(event.data);
        if (json.method === "start") {
          this.userName = json.PlayerData.name;
          this.cardList = json.PlayerData.cards;
        } else if (json.method === "pickup") {
          this.cardList = json.PlayerData.cards;
          if (json.rank > 0) {
            this.clientRank = json.rank;
          }
          if (json.finish) {
            this.finalize();
          }
        } else if (json.method === "discard") {
          this.cardList = json.PlayerData.cards;
          if (json.rank > 0) {
            this.$emit("rank", this.clientId, json.rank);
          }
          if (json.finish) {
            this.finalize();
          }
        } else if (json.method === "target") {
          this.isTarget = json.isTarget;
        } else if (json.method === "sort") {
          this.cardList = json.PlayerData.cards;
        }
      }
    };

    // websocketでエラーが発生した時
    this.webSocket.onerror = (event) => {
      console.log("### websocket.onerror()");
      console.log(event);
    };

    // websocketをクローズした時
    this.webSocket.onclose = (event) => {
      console.log("### websocket.onclose()");
      console.log(event);
    };
  }

  public init(gameId: number, userId: number) {
    this.userName = "";
    this.isTarget = false;
    this.cardList = [];
    this.userId = userId;
    this.gameId = gameId;
    this.clientRank = 0;
    this.sendUserInfo();
  }

  public sendUserInfo() {
    const json = {
      method: "user",
      clientId: this.clientId,
      gameId: this.gameId,
      userId: this.userId,
    };
    if (this.webSocket.readyState == 1) {
      this.webSocket.send(JSON.stringify(json));
    }
  }

  public distribute() {
    const json = {
      method: "distribute",
      gameId: this.gameId,
      userId: this.userId,
    };
    if (this.webSocket.readyState == 1) {
      this.webSocket.send(JSON.stringify(json));
    }
  }

  public discard() {
    const json = {
      method: "discard",
      gameId: this.gameId,
      userId: this.userId,
    };
    if (this.webSocket.readyState == 1) {
      this.webSocket.send(JSON.stringify(json));
    }
  }

  public pickup(card: Card) {
    const json = {
      method: "pickup",
      gameId: this.gameId,
      userId: this.userId,
      localId: card.localId,
    };
    if (this.webSocket.readyState == 1) {
      this.webSocket.send(JSON.stringify(json));
    }
  }

  public sort() {
    const json = {
      method: "sort",
      gameId: this.gameId,
      userId: this.userId,
      cards: this.cardList,
    };
    this.webSocket.send(JSON.stringify(json));
  }

  public finalize() {
    if (this.cardList.length > 0) {
      setTimeout(() => {
        this.cardList = [
          {
            id: "j0",
            localId: -1,
          },
        ];
      }, 1000);
    }
  }
}
</script>

<style scoped>
.cards-container {
  display: flex;
  justify-content: space-evenly;
}
.card-image {
  width: 80px;
}
.back-image {
  width: 50px;
}
@keyframes borderFlashing {
  0% {
    border: 2px solid #45f53e;
  }
  100% {
    border: 2px solid transparent;
  }
}
.emphasis {
  border: 2px solid #45f53e;
  animation: borderFlashing 0.5s ease infinite alternate;
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
.main-win {
  margin-right: 50px;
  font-size: 50px;
  color: #00bcd4;
  text-shadow: 2px 2px #fff, 5px 5px rgba(0, 188, 212, 0.4);
}
.other-win {
  margin-right: 30px;
  font-size: 30px;
  color: #00bcd4;
  text-shadow: 2px 2px #fff, 5px 5px rgba(0, 188, 212, 0.4);
}
</style>
