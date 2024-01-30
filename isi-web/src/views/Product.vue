<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { useStore } from "vuex";
import { useRoute, useRouter } from "vue-router";
import Carousel from "../components/Carousel.vue";
import config from "../config";
import axios from "axios";

const store = useStore();

// const address = computed(() => {
//   return store.state.primaryAddress.addrId;
// });

const router = useRouter();

const addrId = computed(() => {
  return store.state.primaryAddress.addrId;
});

const accId = computed(() => {
  return store.state.accId;
});

const route = useRoute();

type image = {
  image: string
};

type ProductState = {
  id: number;
  title: string;
  collections: string;
  price: number;
  images: Array<image>;
  description: string;
};

type AddressState = {
  ADDRID: string;
  TEL: string;
  NAME: string;
  CITY: string;
  COUNTRY: string;
  DETAILED: string;
  ACCID: string;
  TAG: string;
};

const userStatus = store.state.userStatus;

const address = ref({} as AddressState);

// const query =
//     "http://" + config.apiServer + ":" + config.port + "/api/address_by_id/" + addrId.value;
// axios.get(query).then((res) => {
//   const addressList = res.data.address;
//   address.value = addressList as AddressState;
// });

const product = reactive({} as ProductState);

const buttonLabel = ref("Add to Shopping Cart");

const addToAvalableCart = (cartID) =>{
    const query =
      "http://" +
      config.apiServer +
      ":" +
      config.port +
      "/store/carts/" + cartID + "/items/";
    axios.post(query, { product_id: product.id, quantity: 1 });

}
const addToCart = () => {
  if (buttonLabel.value === "In Shopping Cart") {
    alert("Already in cart");
    return
  }
  if (userStatus === "visitor") {
    router.push("/" + route.params.pid + "/login")
    return
  }
  if (localStorage.getItem("cart-"+store.state.userName)) {
    const cartID = localStorage.getItem("cart-"+store.state.userName);
    addToAvalableCart(cartID)
    alert(cartID)
  } else {
    const query =
      "http://" +
      config.apiServer +
      ":" +
      config.port +
      "/store/carts/";
    axios.post(query, {}).then((res) => {
      console.log(res)
      if (res.status === 201) {
        const cartID = res.data.id
        localStorage.setItem("cart-"+store.state.userName, cartID)
        addToAvalableCart(cartID)
      } else {
      }
    })
  }
  buttonLabel.value = "In Shopping Cart";
};
const addItemToCart = (cartID) => {
  const query =
    "http://" +
    config.apiServer +
    ":" +
    config.port +
    "/store/carts/" + cartID;
  axios.get(query);

}
axios
  .get(
    "http://" + config.apiServer + ":" + config.port + "/store/products/" + route.params.pid
  )
  .then((res) => {
    // console.log(
    //   "http://" +
    //     config.apiServer +
    //     ":" +
    //     config.port +
    //     "/api/product/" +
    //     route.params.pid
    // );
    const json = res.data;
    console.log(json.images)
    product.id = json.id;
    product.title = json.title;
    product.collections = json.collections;
    product.price = json.price;
    product.description = json.description;
    product.images = json.images;

    // console.log(product);
  })
  .catch((error) => console.log(error));

const activeTab = computed(() => {
  return store.state.activeTab;
});

const currentViewOrderId = computed(() => {
  return store.state.currentViewOrderId;
});

const editProduct = () => {
  router.push('/product/' + route.params.pid + '/update')
}
</script>

<template>
  <div class="min-h-full flex items-center justify-center py-6 px-4 lg:px-8">
    <div class="max-w-md w-full space-y-4">
      <router-link v-if="activeTab === 'order'" :to="`/order/${currentViewOrderId}`">
        <div class="text-orange-500">
          <div class="inline text-xl">&lsaquo;&nbsp;</div>
          <div class="inline text-md">Go Back</div>
        </div>
      </router-link>
      <router-link v-else-if="activeTab === 'cart'" to="/cart">
        <div class="text-orange-500">
          <div class="inline text-xl">&lsaquo;&nbsp;</div>
          <div class="inline text-md">Go Back</div>
        </div>
      </router-link>
      <router-link v-else to="/">
        <div class="text-orange-500">
          <div class="inline text-xl">&lsaquo;&nbsp;</div>
          <div class="inline text-md">Go Back</div>
        </div>
      </router-link>
      <div class="bg-white w-full rounded-lg overflow-hidden border shadow-sm">
        <div>
          <!-- <img v-for="pic in product.pic" :src="pic" alt="Product" /> -->
          <!-- <img :src="product.pic" alt="" /> -->
          <Carousel :pic="product.images" />
        </div>
        <div class="px-6 py-4">
          <h2 class="text-left text-2xl font-medium text-gray-900">
            {{ product.title }}, <span class="font-bold">{{ product.collections }}</span>
            <div class="my-2 text-xl font-medium text-orange-500">
              $ {{ product.price }}
            </div>
            <div class="text-sm text-gray-500">
              {{ product.description }}
            </div>
          </h2>
        </div>
      </div>
      <div v-if="userStatus != 'vendor'">
        <div class="bg-white w-full rounded-lg overflow-hidden border shadow-sm">
          <button type="submit"
            class="group relative w-full flex justify-center py-3 px-6 border border-transparent font-medium rounded-md rounded-b-none shadow-sm text-white bg-orange-600 hover:bg-orange-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-800"
            @click="addToCart">
            {{ buttonLabel }}
          </button>
          <router-link to="/address_list" v-if="userStatus === 'active'">
            <div class="px-6 py-4" v-if="addrId != ''">
              <div class="font-medium text-xl mb-2">Shipping to</div>
              <div class="grid grid-cols-3">
                <div class="col-span-1 text-md font-bold mb-2">{{ address.NAME }}</div>
                <div class="col-span-2 text-right text-md mb-2">{{ address.TEL }}</div>
              </div>
              <div class="col-span-1 text-md bold mb-2">
                {{ address.CITY }}, {{ address.COUNTRY }}
              </div>
              <div class="col-span-1 text-md bold mb-2">
                {{ address.DETAILED }}
              </div>
              <p class="text-gray-700 text-base"></p>
            </div>
            <div class="px-6 py-4" v-else>
              <button type="submit"
                class="group relative w-full flex justify-center py-3 px-6 border border-transparent font-medium rounded-md shadow-sm text-white bg-teal-700 hover:bg-teal-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-800"
                @click="router.push('/address_list')">
                Select Primary Address
              </button>
            </div>
          </router-link>
        </div>
      </div>
      <div v-if="userStatus === 'vendor'">
        <div class="bg-white w-full rounded-lg overflow-hidden border shadow-sm">
          <button type="submit"
            class="group relative w-full flex justify-center py-3 px-6 border border-transparent font-medium rounded-md rounded-b-none shadow-sm text-white bg-orange-600 hover:bg-orange-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-800"
            @click="editProduct">
            Edit This Product
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
