<script setup lang="ts">
// // @ts-nocheck
import {computed} from "vue";
import axios from "axios";
import config from "../config";
import {useStore} from "vuex";
import {useRouter} from "vue-router";

const store = useStore();
const router = useRouter();

const accId = computed(() => {
  return store.state.accId;
});

const props = defineProps<{ pid: string; quant: number }>();

const changeQuantity = (v: number) =>{
  const cartID = localStorage.getItem("cart-"+store.state.userName);
  console.log(props)
    const query =
      "http://" +
      config.apiServer +
      ":" +
      config.port +
      "/store/carts/" + cartID + "/items/";
    axios.post(query, { product_id: props.pid , quantity: v }).then(()=>{

    location.reload(); // responsive alternative
    })
};

// const handleChange = (v: number) => {
//   // console.log(`update:value(${v})`);
//   const query =
//       "http://" +
//       config.apiServer +
//       ":" +
//       config.port +
//       "/api/cart/update/" +
//       props.pid +
//       "/" +
//       accId.value +
//       "/" +
//       v;
//   // console.log(query);
//   axios.get(query);
//   location.reload(); // responsive alternative
//   // router.push("/cart/");
// }
</script>

<template>
  <n-space vertical class="w-36">
    <n-input-number
        min="1"
        size="small"
        v-model:value="quant"
        @update:value="changeQuantity"
    >
      <template #prefix>Qty</template>
    </n-input-number>
  </n-space>
</template>
