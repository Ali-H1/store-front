<script lang="ts" setup>
/** Yajing Liu: 
 * It is the frontend about changing passwords. 
 * The major function of this page of code is to show a view for users to change their passwords and send requests to backend.  */
import axios from "axios";
import { computed, ref } from "vue";
import config from "../config"
import { useRouter } from 'vue-router'
import { useStore } from 'vuex'

const router = useRouter()
const store = useStore()

const email = ref("")

const rememberPassword = () => {
  const query = "http://" + config.apiServer + ":" + config.port + "/auth/users/reset_password/"
  axios.post(query,
    {
      email: email.value,
    }, ).then((res) => {
    if (res.data.status === 204) {
      alert(res.data)
      router.push('/profile')
    } else {
      alert(res.status)
    }
  })
}


</script>

<template>
  <div class="min-h-full flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <img alt="Workflow" class="mx-auto h-12 w-auto"
          src="https://tailwindui.com/img/logos/workflow-mark-indigo-600.svg" />
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Forgotten Password
        </h2>
      </div>

      <div class="rounded-md shadow-sm -space-y-px">
        <div>
          <label class="sr-only" for="email-address">Email address</label>
          <input id="oldPassword" v-model="email" autocomplete="email"
            class="appearance-none rounded-none relative block w-full px-3 py-4 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
            name="email" placeholder="Email" required type="email" />
        </div>
      </div>

      <div class="flex items-center justify-between">
        <div class="flex items-center">
        </div>
      </div>

      <div>
        <button
          class="group relative w-full flex justify-center py-3 px-6 border border-transparent font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          type="submit" @click="rememberPassword">
          Remember Password
        </button>
      </div>
    </div>
  </div>
  <div class="min-h-full flex items-center justify-center">
    <div class="rounded-md shadow-sm">
    </div>
  </div>
</template>