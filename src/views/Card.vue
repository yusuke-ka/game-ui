<template>
  <div class="container">
    <div class="header">
      <Entry @entry="entryGame" />
    </div>
    <div class="left">
      <CardList clientId="1" ref="op1" />
    </div>
    <div class="upper">
      <CardList clientId="2" ref="op2" />
    </div>
    <div class="right">
      <CardList clientId="3" ref="op3" />
    </div>
    <div class="lower">
      <CardList clientId="0" ref="main" />
    </div>
    <div class="footer"></div>
    <div class="center">
      <ThrownCard ref="thrown" />
    </div>
  </div>
</template>

<script>
import Entry from "@/components/Entry.vue";
import CardList from "@/components/CardList.vue";
import ThrownCard from "@/components/ThrownCard.vue";

export default {
  name: "Card",
  components: {
    Entry,
    CardList,
    ThrownCard,
  },
  methods: {
    entryGame(userId, gameId) {
      this.$refs.main.init(gameId, userId);
      this.$refs.op1.init(gameId, userId);
      this.$refs.op2.init(gameId, userId);
      this.$refs.op3.init(gameId, userId);
      this.$refs.thrown.init(gameId, userId);
    }
  },
};
</script>

<style>
.container {
  display: grid;
  grid-template-columns: 1fr 1fr 2fr 1fr 1fr;
  grid-template-rows: 1fr 1fr 1fr 1fr 1fr 1fr;
  background-image: url("/img/table.png");
  background-size: 100% 100%;
  height: 100%;
  perspective: 500px;
}
.header {
  grid-column-start: 1;
  grid-column-end: 6;
  grid-row-start: 1;
  grid-row-end: 2;
}

.left {
  grid-column-start: 1;
  grid-column-end: 3;
  grid-row-start: 3;
  grid-row-end: 5;
  transform: rotate(-90deg) rotateY(20deg) skewX(-50deg);
}

.upper {
  grid-column-start: 3;
  grid-column-end: 4;
  grid-row-start: 2;
  grid-row-end: 3;
  transform: rotateX(-15deg);
}

.right {
  grid-column-start: 4;
  grid-column-end: 6;
  grid-row-start: 3;
  grid-row-end: 5;
  transform: rotate(90deg) rotateY(-20deg) skewX(50deg);
}

.center {
  grid-column-start: 3;
  grid-column-end: 4;
  grid-row-start: 3;
  grid-row-end: 4;
  transform: rotateX(15deg);
}

.lower {
  grid-column-start: 1;
  grid-column-end: 6;
  grid-row-start: 5;
  grid-row-end: 6;
  transform: rotateX(-5deg);
}
.footer {
  grid-column-start: 1;
  grid-column-end: 6;
  grid-row-start: 6;
  grid-row-end: 7;
}
</style>
