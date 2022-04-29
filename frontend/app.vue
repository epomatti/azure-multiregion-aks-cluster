<script setup>
const pollServer = 'http://localhost:4000'
const polls = await useAsyncData('count', () => $fetch(`${pollServer}/api/polls`))
</script>

<template>
  <h1>Pools</h1>
  Page visits: {{ polls }}
</template>