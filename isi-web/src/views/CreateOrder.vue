<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { useStore } from "vuex";
import axios from "axios";
import config from "../config";
import router from "../router/router";

const store = useStore();

const activeTab = computed(() => {
  return store.state.activeTab;
});

const addrId = computed(() => {
  return store.state.primaryAddress.addrId;
});

const userEmail = computed(() => {
  return store.state.userEmail;
});

type ProductState = {
  pid: string;
  title: string;
  price: number;
  pdesc: string;
  thumbnail: string;
  pic: string;
  quantity: number;
};

const accId = computed(() => {
  return store.state.accId;
});

const subtotal = ref(0);

const products = reactive([] as Array<ProductState>);
function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) return parts.pop()?.split(';').shift();
}

if (localStorage.getItem("cart-"+store.state.userName)) {
  const cartID = localStorage.getItem("cart-"+store.state.userName);
  const query =
    "http://" + config.apiServer + ":" + config.port + "/store/carts/" + cartID + "/items/";
  axios.get(query, {
    headers: {
      Authorization: getCookie("Authorization") ?? "" //the token is a variable which holds the token
    }
  }).then((res) => {
    const cartItems = res.data.results;
    cartItems.forEach((cartItem) => {
      const pid = cartItem.product.id;
      const quantity = cartItem.quantity;
      console.log(cartItem.product)
      const innerQuery =
        "http://" + config.apiServer + ":" + config.port + "/store/products/" + pid;
      axios.get(innerQuery).then((res) => {
        const img = res.data?.images[0]?.image;
        const product = {
          pid: cartItem.product.id,
          title: cartItem.product.title,
          price: cartItem.product.price,
          pdesc: res.data.pdesc,
          thumbnail: img,
          pic: img,
          quantity: quantity,
        };
        subtotal.value += Number((product.price * product.quantity).toPrecision(3));
        products.push(product);
      });
    });
  });
}
const sortedProducts = products.sort((a, b) => {
  if (a.title < b.title) {
    return -1;
  }
  if (a.title > b.title) {
    return 1;
  }
  return 0;
});

const createOrder = () => {
  const cartID = localStorage.getItem("cart-"+store.state.userName);
  const query =
    "http://" +
    config.apiServer +
    ":" +
    config.port +
    "/store/orders/"
  axios.post(query, { cart_id: cartID }, {
    headers: { Authorization: getCookie("Authorization") ?? "" }
  }).then((response) => {
    console.log(response.data)
    //store.commit("chgActiveTab", "order");
    //router.push("/order/" + response.data.PONO);
  });
};
// const order = {
//   user_email: userEmail.value,
//   subtotal: subtotal.value,
//   products: products,
// };
// axios.post(query, order).then((res) => {
//   if (res.data.success) {
//     alert("Order created successfully!");
//     window.location.href = "/";
//   } else {
//     alert("Order creation failed!");
//   }
// });
</script>

<template>
  <!-- This example requires Tailwind CSS v2.0+ -->
  <div class="max-w-screen">
    <div class="grid md:grid-cols-1 lg:grid-cols-3">
      <div class="lg:col-span-2">
        <div class="flex-1 py-6 overflow-y-auto px-4 sm:px-6">
          <router-link to="/cart">
            <div class="pb-3 text-indigo-800">
              <div class="inline text-xl">&lsaquo;&nbsp;</div>
              <div class="inline text-md">Go Back</div>
            </div>
          </router-link>
          <div class="flex items-start justify-between">
            <h2 class="text-left text-2xl font-medium text-gray-900">
              Create Order
              <div class="text-sm text-gray-500">
                {{ userEmail }}
              </div>
            </h2>
            <div class="ml-3 h-7 flex items-center"></div>
          </div>
          <div class="bg-white rounded-lg p-4 mt-8 shadow-sm border-gray-300 border-b-0 rounded-b-none">
            <div class="flow-root">
              <ul role="list" class="-my-6 divide-y divide-gray-200">
                <li v-for="product in sortedProducts" class="py-6 flex">
                  <div class="flex-shrink-0 w-24 h-24 border border-gray-200 rounded-md overflow-hidden">
                    <img :src="product.thumbnail" class="w-full h-full object-center object-cover" />
                  </div>

                  <div class="ml-4 flex-1 flex flex-col">
                    <div>
                      <div class="flex justify-between text-base font-medium text-gray-900">
                        <h3>
                          {{ product.title }}
                        </h3>

                        <p class="ml-4">${{ product.price }}</p>
                      </div>
                    </div>
                    <div class="flex-1 flex items-end justify-between text-sm">
                      Qty: {{ product.quantity }}
                    </div>
                  </div>
                </li>
              </ul>
            </div>
          </div>
          <div class="p-4 border-t-transparent rounded-none shadow-sm border-gray-300 bg-gray-200 text-white">
            <div class="flow-root">
              <div class="col-span-1 flex flex-col">
                <div class="">
                  <div class="flex justify-between text-base font-medium text-gray-900">
                    <p>Subtotal</p>
                    <p>${{ subtotal }}</p>
                  </div>
                  <p class="mt-0.5 text-sm text-gray-600">
                    Shipping and taxes calculated at checkout.
                  </p>
                  <div class="flex justify-center text-sm text-center text-gray-500"></div>
                </div>
              </div>
            </div>
          </div>
          <div class="mt-0">
            <button
              class="w-full flex justify-center items-center px-6 py-3 border border-transparent rounded-md shadow-sm text-base font-medium text-white bg-indigo-600 hover:bg-indogo-800 rounded-t-none"
              @click="createOrder">
              Pay
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
