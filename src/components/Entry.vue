<template>
  <div>
    <div v-if="noEntry" class="inputWrapper clearfix">
      <div class="txtWrapper">
        <label class="ef">
          <input
            type="text"
            v-model="userName"
            @keypress.enter="entry"
            placeholder="YOUR NAME"
            maxlength="15"
          />
        </label>
      </div>
      <div class="btnWrapper">
        <button class="btn" @click="entry">Entry</button>
      </div>
    </div>
    <div v-else>
      <h2>{{ message }}</h2>
      <div v-if="notStarted">
        <button class="btn" @click="start">Start</button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import axios from "axios";

@Component
export default class CardList extends Vue {
  public noEntry = true;
  public notStarted = true;
  public gameId: number | null = null;
  public userId: number | null = null;
  public userName = "";
  public message = "";
  public playerList = [];
  private server = process.env.VUE_APP_SERVER;
  private baseUrl = "http://" + this.server + ":3000/";
  private webSocket = new WebSocket("ws://" + this.server + ":3000/game");

  public async entry() {
    if (!this.userName) {
      return;
    }
    try {
      const params = {
        userName: this.userName,
        status: 1,
      };
      const response = await axios.post(this.baseUrl + "entry", params);
      console.log(response.data);
      this.gameId = response.data.gameId;
      this.userId = response.data.userId;
      this.$emit("entry", this.userId, this.gameId);
      const json = {
        method: "entry",
        gameId: this.gameId,
        userId: this.userId,
      };
      if (this.webSocket.readyState == 1) {
        this.webSocket.send(JSON.stringify(json));
      }
    } catch (e) {
      return e;
    } finally {
      this.noEntry = false;
    }
  }

  public mounted() {
    console.log(process.env);
    this.webSocket.onopen = (event) => {
      console.log(event);
    };

    this.webSocket.onmessage = (event) => {
      if (event && event.data) {
        const json = JSON.parse(event.data);
        if (json.method === "instruction") {
          this.message = json.message;
          this.notStarted = !json.started;
          this.noEntry = json.initialize;
        }
      }
    };

    this.webSocket.onerror = (event) => {
      console.log(event);
    };

    this.webSocket.onclose = (event) => {
      console.log(event);
    };
  }

  public start() {
    this.notStarted = false;
    const json = {
      method: "start",
      gameId: this.gameId,
    };
    if (this.webSocket.readyState == 1) {
      this.webSocket.send(JSON.stringify(json));
    }
  }
}
</script>

<style scoped>
.clearfix::after {
  content: "";
  display: block;
  clear: both;
}
.inputWrapper {
  position: relative;
  width: 380px;
  margin: auto;
  display: block;
}
.inputWrapper input[type="text"] {
  font: 15px/24px sans-serif;
  box-sizing: border-box;
  width: 100%;
  padding: 0.3em;
  transition: 0.3s;
  letter-spacing: 1px;
  border: 1px solid #1b2538;
  border-radius: 4px;
}
.ef input[type="text"]:focus {
  border: 1px solid #da3c41;
  outline: none;
  box-shadow: 0 0 5px 1px rgba(218, 60, 65, 0.5);
}
.txtWrapper {
  float: left;
  width: 270px;
}
.btnWrapper {
  float: right;
}
.btn {
  position: relative;
  display: block;
  text-decoration: none;
  color: #fff;
  background: #007bff;
  border: solid 1px #007bff;
  border-radius: 4px;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.2);
  text-shadow: 0 1px 0 rgba(0, 0, 0, 0.2);
  width: 100px;
  height: 35px;
  font-size: 16px;
  margin-left: auto;
  margin-right: auto;
}
h2 {
  position: relative;
  padding: 0.3em 0.5em;
  background: -webkit-linear-gradient(to top, rgb(137, 184, 255), #c5ceff);
  background: linear-gradient(to top, rgb(137, 184, 255), #c5ceff);
  color: #ffffff;
  text-shadow: 2px 2px rgb(37, 145, 153), 5px 5px rgba(0, 188, 212, 0.4);
}
</style>
