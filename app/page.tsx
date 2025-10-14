"use client"

import { useState, useEffect } from "react"
import {
  Home,
  Users,
  MessageCircle,
  User,
  Settings,
  ArrowRight,
  Heart,
  Flame,
  Moon,
  ArrowLeft,
  Send,
  TrendingUp,
  Calendar,
  Target,
  Sun,
  BarChart3,
  Plus,
  X,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Label } from "@/components/ui/label"

type HealthData = {
  steps: number[]
  sleep: number[]
  calories: number[]
  date: string
}

type Post = {
  id: string
  user: string
  time: string
  content: string
  likes: number
  comments: number
  likedByUser: boolean
}

export default function HealthTeenApp() {
  const [activeTab, setActiveTab] = useState("home")
  const [currentView, setCurrentView] = useState<string>("main")
  const [selectedMetric, setSelectedMetric] = useState<string>("")
  const [selectedGroup, setSelectedGroup] = useState<string>("")
  const [selectedChat, setSelectedChat] = useState<string>("")

  const [healthData, setHealthData] = useState<HealthData>(() => {
    if (typeof window !== "undefined") {
      const saved = localStorage.getItem("healthData")
      if (saved) return JSON.parse(saved)
    }
    return {
      steps: [5234, 7891, 6543, 8234, 6234, 9123, 7456],
      sleep: [7.5, 6.8, 8.2, 7.0, 7.75, 8.5, 7.2],
      calories: [1650, 1890, 2100, 1750, 1850, 2200, 1920],
      date: new Date().toISOString().split("T")[0],
    }
  })

  const [posts, setPosts] = useState<Post[]>(() => {
    if (typeof window !== "undefined") {
      const saved = localStorage.getItem("posts")
      if (saved) return JSON.parse(saved)
    }
    return [
      {
        id: "1",
        user: "Liam",
        time: "2h",
        content:
          "Just finished a great workout! Feeling energized and ready to tackle the day. #fitness #healthylifestyle",
        likes: 23,
        comments: 5,
        likedByUser: false,
      },
      {
        id: "2",
        user: "Sophia",
        time: "4h",
        content:
          "Made a delicious and nutritious smoothie this morning. Packed with fruits and veggies! #healthyfood #smoothierecipe",
        likes: 32,
        comments: 8,
        likedByUser: false,
      },
      {
        id: "3",
        user: "Ethan",
        time: "6h",
        content:
          "Took some time for mindfulness and meditation today. Feeling calm and focused. #mentalhealth #mindfulness",
        likes: 15,
        comments: 2,
        likedByUser: false,
      },
    ]
  })

  const [showLogModal, setShowLogModal] = useState(false)
  const [logType, setLogType] = useState<"steps" | "sleep" | "calories" | null>(null)

  useEffect(() => {
    if (typeof window !== "undefined") {
      localStorage.setItem("healthData", JSON.stringify(healthData))
    }
  }, [healthData])

  useEffect(() => {
    if (typeof window !== "undefined") {
      localStorage.setItem("posts", JSON.stringify(posts))
    }
  }, [posts])

  const updateHealthData = (type: keyof HealthData, value: any) => {
    setHealthData((prev) => {
      const newData = { ...prev }
      const today = new Date().toISOString().split("T")[0]

      // Update today's data (last item in array)
      if (Array.isArray(newData[type])) {
        const arr = [...(newData[type] as any[])]
        arr[arr.length - 1] = value
        newData[type] = arr as any
      }

      newData.date = today
      return newData
    })
  }

  const toggleLike = (postId: string) => {
    setPosts((prev) =>
      prev.map((post) =>
        post.id === postId
          ? {
              ...post,
              likes: post.likedByUser ? post.likes - 1 : post.likes + 1,
              likedByUser: !post.likedByUser,
            }
          : post,
      ),
    )
  }

  const navigateToDetail = (view: string, data?: string) => {
    setCurrentView(view)
    if (data) {
      if (view === "metric-detail") setSelectedMetric(data)
      if (view === "group-detail") setSelectedGroup(data)
      if (view === "chat-detail") setSelectedChat(data)
    }
  }

  const navigateBack = () => {
    setCurrentView("main")
    setSelectedMetric("")
    setSelectedGroup("")
    setSelectedChat("")
  }

  const openLogModal = (type: "steps" | "sleep" | "calories") => {
    setLogType(type)
    setShowLogModal(true)
  }

  return (
    <div className="mx-auto flex h-screen max-w-[430px] flex-col bg-background">
      {/* Header */}
      <header className="flex items-center justify-between border-b border-border bg-card px-4 py-3">
        {currentView !== "main" ? (
          <Button variant="ghost" size="icon" className="h-9 w-9" onClick={navigateBack}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
        ) : null}
        <h1 className="text-lg font-semibold">
          {currentView === "main"
            ? "Health Teen"
            : currentView === "metric-detail"
              ? selectedMetric
              : currentView === "group-detail"
                ? selectedGroup
                : currentView === "chat-detail"
                  ? selectedChat
                  : currentView === "dashboard"
                    ? "Dashboard"
                    : currentView}
        </h1>
        <Button variant="ghost" size="icon" className="h-9 w-9">
          <Settings className="h-5 w-5" />
        </Button>
      </header>

      {/* Main Content */}
      <main className="flex-1 overflow-hidden">
        {currentView === "main" && (
          <>
            {activeTab === "home" && (
              <HomeTab onNavigate={navigateToDetail} healthData={healthData} onLog={openLogModal} />
            )}
            {activeTab === "community" && (
              <CommunityTab onNavigate={navigateToDetail} posts={posts} onToggleLike={toggleLike} />
            )}
            {activeTab === "chat" && <ChatTab onNavigate={navigateToDetail} />}
            {activeTab === "profile" && <ProfileTab onNavigate={navigateToDetail} healthData={healthData} />}
          </>
        )}
        {currentView === "metric-detail" && <MetricDetailView metric={selectedMetric} healthData={healthData} />}
        {currentView === "group-detail" && <GroupDetailView group={selectedGroup} />}
        {currentView === "chat-detail" && <ChatDetailView chatName={selectedChat} />}
        {currentView === "settings" && <SettingsView />}
        {currentView === "dashboard" && <DashboardView healthData={healthData} />}
      </main>

      {/* Bottom Navigation - only show on main view */}
      {currentView === "main" && (
        <nav className="flex items-center justify-around border-t border-border bg-card px-2 py-2 safe-bottom">
          <Button
            variant={activeTab === "home" ? "default" : "ghost"}
            size="sm"
            className="flex h-14 flex-col gap-0.5 px-3"
            onClick={() => setActiveTab("home")}
          >
            <Home className="h-5 w-5" />
            <span className="text-[10px]">Home</span>
          </Button>
          <Button
            variant={activeTab === "community" ? "default" : "ghost"}
            size="sm"
            className="flex h-14 flex-col gap-0.5 px-3"
            onClick={() => setActiveTab("community")}
          >
            <Users className="h-5 w-5" />
            <span className="text-[10px]">Community</span>
          </Button>
          <Button
            variant={activeTab === "chat" ? "default" : "ghost"}
            size="sm"
            className="flex h-14 flex-col gap-0.5 px-3"
            onClick={() => setActiveTab("chat")}
          >
            <MessageCircle className="h-5 w-5" />
            <span className="text-[10px]">Chat</span>
          </Button>
          <Button
            variant={activeTab === "profile" ? "default" : "ghost"}
            size="sm"
            className="flex h-14 flex-col gap-0.5 px-3"
            onClick={() => setActiveTab("profile")}
          >
            <User className="h-5 w-5" />
            <span className="text-[10px]">Profile</span>
          </Button>
        </nav>
      )}

      {showLogModal && logType && (
        <LogModal
          type={logType}
          currentValue={
            logType === "steps"
              ? healthData.steps[healthData.steps.length - 1]
              : logType === "sleep"
                ? healthData.sleep[healthData.sleep.length - 1]
                : healthData.calories[healthData.calories.length - 1]
          }
          onSave={(value) => {
            updateHealthData(logType, value)
            setShowLogModal(false)
            setLogType(null)
          }}
          onClose={() => {
            setShowLogModal(false)
            setLogType(null)
          }}
        />
      )}
    </div>
  )
}

function LogModal({
  type,
  currentValue,
  onSave,
  onClose,
}: {
  type: "steps" | "sleep" | "calories"
  currentValue: any
  onSave: (value: any) => void
  onClose: () => void
}) {
  const [value, setValue] = useState(currentValue)

  const handleSave = () => {
    const numValue = Number.parseFloat(value)
    if (!isNaN(numValue) && numValue >= 0) {
      onSave(numValue)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <Card className="w-full max-w-sm">
        <CardContent className="p-6">
          <div className="mb-4 flex items-center justify-between">
            <h3 className="text-lg font-semibold">Log {type.charAt(0).toUpperCase() + type.slice(1)}</h3>
            <Button variant="ghost" size="icon" className="h-8 w-8" onClick={onClose}>
              <X className="h-4 w-4" />
            </Button>
          </div>

          <div className="space-y-3">
            <Label>
              {type === "steps" && "Steps taken today"}
              {type === "sleep" && "Hours of sleep"}
              {type === "calories" && "Calories burned"}
            </Label>
            <Input
              type="number"
              value={value}
              onChange={(e) => setValue(e.target.value)}
              placeholder={`Enter ${type}`}
              className="text-lg"
              step={type === "sleep" ? "0.1" : "1"}
              min="0"
            />
          </div>

          <div className="mt-6 flex gap-2">
            <Button variant="outline" className="flex-1 bg-transparent" onClick={onClose}>
              Cancel
            </Button>
            <Button className="flex-1" onClick={handleSave}>
              Save
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

function HomeTab({
  onNavigate,
  healthData,
  onLog,
}: {
  onNavigate: (view: string, data?: string) => void
  healthData: HealthData
  onLog: (type: "steps" | "sleep" | "calories") => void
}) {
  const todaySteps = healthData.steps[healthData.steps.length - 1]
  const todaySleep = healthData.sleep[healthData.sleep.length - 1]
  const todayCalories = healthData.calories[healthData.calories.length - 1]

  return (
    <ScrollArea className="h-full">
      <div className="space-y-4 p-4 pb-6">
        <div>
          <h2 className="mb-3 text-xl font-bold">Today's Health</h2>

          {/* Steps Card */}
          <Card className="mb-3 overflow-hidden bg-gradient-to-br from-primary/10 to-accent/10">
            <CardContent className="p-4">
              <div className="flex items-end justify-between">
                <div>
                  <p className="text-xs text-muted-foreground">Steps</p>
                  <p className="text-3xl font-bold">{todaySteps.toLocaleString()}</p>
                  <p className="text-xs text-muted-foreground">Daily steps</p>
                </div>
                <Button variant="ghost" size="icon" className="h-10 w-10" onClick={() => onLog("steps")}>
                  <Plus className="h-5 w-5" />
                </Button>
              </div>
              <Button variant="ghost" size="sm" className="mt-3 h-8 text-xs" onClick={() => onNavigate("dashboard")}>
                View Dashboard <ArrowRight className="ml-1 h-3 w-3" />
              </Button>
            </CardContent>
          </Card>

          {/* Sleep Card */}
          <Card className="mb-3">
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">Sleep</p>
                  <p className="text-2xl font-bold">{todaySleep}h</p>
                  <p className="text-xs text-muted-foreground">Sleep duration</p>
                </div>
                <Button variant="ghost" size="icon" className="h-10 w-10" onClick={() => onLog("sleep")}>
                  <Plus className="h-5 w-5" />
                </Button>
              </div>
              <Button
                variant="ghost"
                size="sm"
                className="mt-3 h-8 text-xs"
                onClick={() => onNavigate("metric-detail", "Sleep")}
              >
                View <ArrowRight className="ml-1 h-3 w-3" />
              </Button>
            </CardContent>
          </Card>

          {/* Calories Card */}
          <Card className="bg-gradient-to-br from-orange-500/10 to-red-500/10">
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex-1">
                  <p className="text-xs text-muted-foreground">Calories</p>
                  <p className="text-2xl font-bold">{todayCalories.toLocaleString()}</p>
                  <p className="text-xs text-muted-foreground">Calories burned</p>
                </div>
                <Button variant="ghost" size="icon" className="h-10 w-10" onClick={() => onLog("calories")}>
                  <Plus className="h-5 w-5" />
                </Button>
              </div>
              <Button
                variant="ghost"
                size="sm"
                className="mt-3 h-8 text-xs"
                onClick={() => onNavigate("metric-detail", "Calories")}
              >
                View <ArrowRight className="ml-1 h-3 w-3" />
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </ScrollArea>
  )
}

function CommunityTab({
  onNavigate,
  posts,
  onToggleLike,
}: {
  onNavigate: (view: string, data?: string) => void
  posts: Post[]
  onToggleLike: (postId: string) => void
}) {
  const groups = [
    { name: "Fitness Teens", image: "/fitness-teens-exercising.jpg" },
    { name: "Healthy Recipes", image: "/healthy-vegetables.png" },
    { name: "Mental Wellness", image: "/meditation-peaceful.jpg" },
  ]

  return (
    <ScrollArea className="h-full">
      <div className="space-y-4 p-4 pb-6">
        {/* Groups Section */}
        <div>
          <h2 className="mb-3 text-lg font-bold">Groups</h2>
          <div className="grid grid-cols-3 gap-2">
            {groups.map((group, i) => (
              <Card
                key={i}
                className="cursor-pointer overflow-hidden transition-all hover:ring-2 hover:ring-primary"
                onClick={() => onNavigate("group-detail", group.name)}
              >
                <img src={group.image || "/placeholder.svg"} alt={group.name} className="h-20 w-full object-cover" />
                <CardContent className="p-2">
                  <p className="text-[10px] font-medium leading-tight">{group.name}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>

        {/* Feed Section */}
        <div>
          <h2 className="mb-3 text-lg font-bold">Feed</h2>
          <div className="space-y-3">
            {posts.map((post) => (
              <Card key={post.id}>
                <CardContent className="p-3">
                  <div className="mb-2 flex items-center gap-2">
                    <Avatar className="h-8 w-8">
                      <AvatarImage src={`/.jpg?height=32&width=32&query=${post.user}`} />
                      <AvatarFallback className="text-xs">{post.user[0]}</AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="text-sm font-semibold">{post.user}</p>
                      <p className="text-[10px] text-muted-foreground">{post.time}</p>
                    </div>
                  </div>
                  <p className="mb-2 text-sm leading-relaxed">{post.content}</p>
                  <div className="flex items-center gap-4 text-xs text-muted-foreground">
                    <button
                      className={`flex items-center gap-1 transition-colors ${
                        post.likedByUser ? "text-red-500" : "hover:text-foreground"
                      }`}
                      onClick={() => onToggleLike(post.id)}
                    >
                      <Heart className={`h-3.5 w-3.5 ${post.likedByUser ? "fill-current" : ""}`} />
                      {post.likes}
                    </button>
                    <button className="flex items-center gap-1 hover:text-foreground">
                      <MessageCircle className="h-3.5 w-3.5" />
                      {post.comments}
                    </button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </div>
    </ScrollArea>
  )
}

function ChatTab({ onNavigate }: { onNavigate: (view: string, data?: string) => void }) {
  const chats = [
    { name: "Liam", lastMessage: "See you at the gym!", time: "2m", unread: true },
    { name: "Nathan", lastMessage: "Thanks for the recipe!", time: "1h", unread: false },
    { name: "MM", lastMessage: "How was your workout?", time: "3h", unread: false },
    { name: "Dom", lastMessage: "Let's catch up soon", time: "5h", unread: false },
    { name: "Jezz", lastMessage: "Great progress!", time: "1d", unread: false },
    { name: "Lana", lastMessage: "See you tomorrow", time: "2d", unread: false },
  ]

  return (
    <div className="flex h-full flex-col">
      <div className="border-b border-border p-3">
        <h2 className="mb-2 text-lg font-bold">Chat</h2>
        <Input placeholder="Search chats..." className="h-9 w-full text-sm" />
      </div>
      <ScrollArea className="flex-1">
        <div className="divide-y divide-border">
          {chats.map((chat, i) => (
            <button
              key={i}
              className="flex w-full items-center gap-3 p-3 text-left transition-colors hover:bg-muted active:bg-muted"
              onClick={() => onNavigate("chat-detail", chat.name)}
            >
              <Avatar className="h-10 w-10">
                <AvatarImage src={`/.jpg?height=40&width=40&query=${chat.name}`} />
                <AvatarFallback className="text-sm">{chat.name[0]}</AvatarFallback>
              </Avatar>
              <div className="flex-1 overflow-hidden">
                <div className="flex items-center justify-between">
                  <p className="text-sm font-semibold">{chat.name}</p>
                  <span className="text-[10px] text-muted-foreground">{chat.time}</span>
                </div>
                <p className="truncate text-xs text-muted-foreground">{chat.lastMessage}</p>
              </div>
              {chat.unread && <div className="h-2 w-2 flex-shrink-0 rounded-full bg-primary" />}
            </button>
          ))}
        </div>
      </ScrollArea>
    </div>
  )
}

function ProfileTab({
  onNavigate,
  healthData,
}: {
  onNavigate: (view: string, data?: string) => void
  healthData: HealthData
}) {
  const avgSleep = (healthData.sleep.reduce((a, b) => a + b, 0) / healthData.sleep.length).toFixed(1)
  const avgCalories = Math.round(healthData.calories.reduce((a, b) => a + b, 0) / healthData.calories.length)

  return (
    <ScrollArea className="h-full">
      <div className="space-y-4 p-4 pb-6">
        {/* Profile Header */}
        <div className="flex flex-col items-center gap-3">
          <Avatar className="h-20 w-20">
            <AvatarImage src="/user-profile-illustration.png" />
            <AvatarFallback>EC</AvatarFallback>
          </Avatar>
          <div className="text-center">
            <h2 className="text-lg font-bold">Ethan Carter</h2>
            <Badge variant="secondary" className="mt-1 text-xs">
              Free Member
            </Badge>
          </div>
        </div>

        {/* Dashboard Stats */}
        <Card>
          <CardContent className="p-4">
            <div className="mb-3 flex items-center justify-between">
              <h3 className="text-sm font-semibold">Dashboard</h3>
              <Button variant="ghost" size="sm" className="h-7 text-xs" onClick={() => onNavigate("dashboard")}>
                <BarChart3 className="mr-1 h-3.5 w-3.5" />
                View All
              </Button>
            </div>
            <div className="grid grid-cols-3 gap-3">
              <div>
                <p className="text-xs text-muted-foreground">Sleep</p>
                <p className="text-xl font-bold">{avgSleep}h</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Calories</p>
                <p className="text-xl font-bold">{avgCalories}</p>
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Steps</p>
                <p className="text-xl font-bold">
                  {Math.round(healthData.steps.reduce((a, b) => a + b, 0) / healthData.steps.length).toLocaleString()}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Account Settings */}
        <Card>
          <CardContent className="p-4">
            <h3 className="mb-3 text-sm font-semibold">Account Settings</h3>
            <div className="space-y-1">
              <Button
                variant="ghost"
                className="h-10 w-full justify-start text-sm"
                onClick={() => onNavigate("settings", "Password")}
              >
                Password
                <ArrowRight className="ml-auto h-4 w-4" />
              </Button>
              <Button
                variant="ghost"
                className="h-10 w-full justify-start text-sm"
                onClick={() => onNavigate("settings", "Privacy")}
              >
                Privacy
                <ArrowRight className="ml-auto h-4 w-4" />
              </Button>
              <Button
                variant="ghost"
                className="h-10 w-full justify-start text-sm"
                onClick={() => onNavigate("settings", "Notifications")}
              >
                Notifications
                <ArrowRight className="ml-auto h-4 w-4" />
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Profile Access */}
        <Card>
          <CardContent className="p-4">
            <h3 className="mb-3 text-sm font-semibold">Profile Access</h3>
            <div className="space-y-1">
              <Button variant="ghost" className="h-10 w-full justify-start text-sm">
                Challenge
                <ArrowRight className="ml-auto h-4 w-4" />
              </Button>
              <Button variant="ghost" className="h-10 w-full justify-start text-sm">
                Community
                <ArrowRight className="ml-auto h-4 w-4" />
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </ScrollArea>
  )
}

function MetricDetailView({ metric, healthData }: { metric: string; healthData: HealthData }) {
  const metricData = {
    Steps: {
      current: healthData.steps[healthData.steps.length - 1].toLocaleString(),
      goal: "10,000",
      unit: "steps",
      icon: TrendingUp,
      color: "text-primary",
      bgColor: "bg-primary/10",
      weekData: healthData.steps,
    },
    Sleep: {
      current: `${healthData.sleep[healthData.sleep.length - 1]}h`,
      goal: "8h",
      unit: "hours",
      icon: Moon,
      color: "text-blue-500",
      bgColor: "bg-blue-500/10",
      weekData: healthData.sleep,
    },
    Calories: {
      current: healthData.calories[healthData.calories.length - 1].toLocaleString(),
      goal: "2,000",
      unit: "kcal",
      icon: Flame,
      color: "text-orange-500",
      bgColor: "bg-orange-500/10",
      weekData: healthData.calories,
    },
  }

  const data = metricData[metric as keyof typeof metricData]
  const Icon = data.icon

  const progress =
    metric === "Steps"
      ? (healthData.steps[healthData.steps.length - 1] / 10000) * 100
      : metric === "Sleep"
        ? (healthData.sleep[healthData.sleep.length - 1] / 8) * 100
        : (healthData.calories[healthData.calories.length - 1] / 2000) * 100

  return (
    <ScrollArea className="h-full">
      <div className="space-y-4 p-4 pb-6">
        {/* Current Status Card */}
        <Card className={data.bgColor}>
          <CardContent className="p-6">
            <div className="mb-4 flex items-center justify-between">
              <div>
                <p className="mb-1 text-sm text-muted-foreground">Current</p>
                <p className="text-4xl font-bold">{data.current}</p>
              </div>
              <div className={`flex h-16 w-16 items-center justify-center rounded-full ${data.bgColor}`}>
                <Icon className={`h-10 w-10 ${data.color}`} />
              </div>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Goal: {data.goal}</span>
                <span className="font-semibold">{Math.round(progress)}%</span>
              </div>
              <div className="h-2 w-full overflow-hidden rounded-full bg-muted">
                <div
                  className={`h-full ${data.color.replace("text-", "bg-")} transition-all`}
                  style={{ width: `${Math.min(progress, 100)}%` }}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Weekly Overview */}
        <Card>
          <CardContent className="p-4">
            <h3 className="mb-4 flex items-center gap-2 text-sm font-semibold">
              <Calendar className="h-4 w-4" />
              This Week
            </h3>
            <div className="space-y-3">
              {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day, i) => (
                <div key={day} className="flex items-center gap-3">
                  <span className="w-8 text-xs text-muted-foreground">{day}</span>
                  <div className="h-8 flex-1 overflow-hidden rounded-full bg-muted">
                    <div
                      className={`flex h-full items-center justify-end pr-2 ${data.color.replace("text-", "bg-")}`}
                      style={{
                        width:
                          metric === "Sleep"
                            ? `${((data.weekData[i] as number) / 10) * 100}%`
                            : metric === "Steps"
                              ? `${((data.weekData[i] as number) / 10000) * 100}%`
                              : `${((data.weekData[i] as number) / 2500) * 100}%`,
                      }}
                    >
                      <span className="text-[10px] font-semibold text-white">{data.weekData[i]}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Insights */}
        <Card>
          <CardContent className="p-4">
            <h3 className="mb-3 flex items-center gap-2 text-sm font-semibold">
              <Target className="h-4 w-4" />
              Insights
            </h3>
            <div className="space-y-2 text-sm">
              <p className="leading-relaxed text-muted-foreground">
                {metric === "Steps" &&
                  `You're ${Math.round(progress)}% towards your daily goal! Keep moving to reach 10,000 steps.`}
                {metric === "Sleep" &&
                  `Great sleep quality this week! You're averaging ${(healthData.sleep.reduce((a, b) => a + b, 0) / healthData.sleep.length).toFixed(1)} hours per night.`}
                {metric === "Calories" &&
                  `You're burning an average of ${Math.round(healthData.calories.reduce((a, b) => a + b, 0) / healthData.calories.length).toLocaleString()} calories daily. Stay consistent!`}
              </p>
              <Button size="sm" className="mt-3 w-full">
                Set New Goal
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </ScrollArea>
  )
}

function GroupDetailView({ group }: { group: string }) {
  const groupData = {
    "Fitness Teens": {
      image: "/fitness-teens-exercising.jpg",
      members: 1234,
      description: "Join fellow fitness enthusiasts to share workouts, tips, and motivation!",
      posts: [
        {
          user: "Alex",
          time: "1h",
          content: "Just completed a 5K run! New personal best! 🏃‍♂️",
          likes: 45,
          comments: 12,
        },
        {
          user: "Sarah",
          time: "3h",
          content: "Anyone want to join me for a morning yoga session tomorrow?",
          likes: 28,
          comments: 8,
        },
        {
          user: "Mike",
          time: "5h",
          content: "Sharing my weekly workout routine. Check it out!",
          likes: 67,
          comments: 15,
        },
      ],
    },
    "Healthy Recipes": {
      image: "/healthy-vegetables.png",
      members: 892,
      description: "Discover and share delicious, nutritious recipes for a healthier lifestyle.",
      posts: [
        {
          user: "Emma",
          time: "2h",
          content: "Made this amazing quinoa bowl today! Recipe in comments 🥗",
          likes: 89,
          comments: 23,
        },
        {
          user: "David",
          time: "4h",
          content: "Looking for high-protein vegetarian meal ideas. Suggestions?",
          likes: 34,
          comments: 19,
        },
        {
          user: "Lisa",
          time: "6h",
          content: "Smoothie Sunday! Here's my favorite green smoothie recipe.",
          likes: 56,
          comments: 11,
        },
      ],
    },
    "Mental Wellness": {
      image: "/meditation-peaceful.jpg",
      members: 756,
      description: "A supportive community for mental health, mindfulness, and self-care.",
      posts: [
        {
          user: "Jordan",
          time: "1h",
          content: "Meditation really helped me today. Feeling so much calmer 🧘",
          likes: 52,
          comments: 9,
        },
        {
          user: "Taylor",
          time: "3h",
          content: "What are your favorite stress-relief techniques?",
          likes: 41,
          comments: 16,
        },
        {
          user: "Casey",
          time: "7h",
          content: "Reminder: It's okay to take a break and prioritize yourself ❤️",
          likes: 78,
          comments: 14,
        },
      ],
    },
  }

  const data = groupData[group as keyof typeof groupData]

  return (
    <ScrollArea className="h-full">
      <div className="space-y-4">
        {/* Group Header */}
        <div className="relative">
          <img src={data.image || "/placeholder.svg"} alt={group} className="h-40 w-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
          <div className="absolute bottom-4 left-4 right-4 text-white">
            <h2 className="mb-1 text-2xl font-bold">{group}</h2>
            <p className="text-sm opacity-90">{data.members.toLocaleString()} members</p>
          </div>
        </div>

        <div className="space-y-4 px-4 pb-6">
          {/* About */}
          <Card>
            <CardContent className="p-4">
              <h3 className="mb-2 text-sm font-semibold">About</h3>
              <p className="leading-relaxed text-sm text-muted-foreground">{data.description}</p>
              <Button className="mt-3 w-full" size="sm">
                Join Group
              </Button>
            </CardContent>
          </Card>

          {/* Posts */}
          <div>
            <h3 className="mb-3 px-1 text-sm font-semibold">Recent Posts</h3>
            <div className="space-y-3">
              {data.posts.map((post, i) => (
                <Card key={i}>
                  <CardContent className="p-3">
                    <div className="mb-2 flex items-center gap-2">
                      <Avatar className="h-8 w-8">
                        <AvatarImage src={`/.jpg?height=32&width=32&query=${post.user}`} />
                        <AvatarFallback className="text-xs">{post.user[0]}</AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="text-sm font-semibold">{post.user}</p>
                        <p className="text-[10px] text-muted-foreground">{post.time}</p>
                      </div>
                    </div>
                    <p className="mb-2 leading-relaxed text-sm">{post.content}</p>
                    <div className="flex items-center gap-4 text-xs text-muted-foreground">
                      <button className="flex items-center gap-1 hover:text-foreground">
                        <Heart className="h-3.5 w-3.5" />
                        {post.likes}
                      </button>
                      <button className="flex items-center gap-1 hover:text-foreground">
                        <MessageCircle className="h-3.5 w-3.5" />
                        {post.comments}
                      </button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </div>
    </ScrollArea>
  )
}

function ChatDetailView({ chatName }: { chatName: string }) {
  const [messages, setMessages] = useState([
    { sender: "them", text: "Hey! How's your fitness journey going?", time: "10:30 AM" },
    { sender: "me", text: "Going great! Just hit my step goal today 🎉", time: "10:32 AM" },
    { sender: "them", text: "That's awesome! Keep it up!", time: "10:33 AM" },
    { sender: "me", text: "Thanks! How about you?", time: "10:35 AM" },
    { sender: "them", text: "See you at the gym!", time: "10:36 AM" },
  ])
  const [newMessage, setNewMessage] = useState("")

  const sendMessage = () => {
    if (newMessage.trim()) {
      const now = new Date()
      const time = now.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" })
      setMessages([...messages, { sender: "me", text: newMessage, time }])
      setNewMessage("")
    }
  }

  return (
    <div className="flex h-full flex-col">
      {/* Chat Header */}
      <div className="border-b border-border bg-card p-3">
        <div className="flex items-center gap-3">
          <Avatar className="h-10 w-10">
            <AvatarImage src={`/.jpg?height=40&width=40&query=${chatName}`} />
            <AvatarFallback>{chatName[0]}</AvatarFallback>
          </Avatar>
          <div>
            <p className="text-sm font-semibold">{chatName}</p>
            <p className="text-xs text-muted-foreground">Active now</p>
          </div>
        </div>
      </div>

      {/* Messages */}
      <ScrollArea className="flex-1 p-4">
        <div className="space-y-4">
          {messages.map((msg, i) => (
            <div key={i} className={`flex ${msg.sender === "me" ? "justify-end" : "justify-start"}`}>
              <div className={`max-w-[75%] space-y-1`}>
                <div
                  className={`rounded-2xl px-4 py-2 ${
                    msg.sender === "me" ? "bg-primary text-primary-foreground" : "bg-muted"
                  }`}
                >
                  <p className="leading-relaxed text-sm">{msg.text}</p>
                </div>
                <p
                  className={`px-2 text-[10px] text-muted-foreground ${msg.sender === "me" ? "text-right" : "text-left"}`}
                >
                  {msg.time}
                </p>
              </div>
            </div>
          ))}
        </div>
      </ScrollArea>

      {/* Message Input */}
      <div className="border-t border-border bg-card p-3">
        <div className="flex items-center gap-2">
          <Input
            placeholder="Send a message..."
            className="h-10 flex-1 text-sm"
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && sendMessage()}
          />
          <Button size="icon" className="h-10 w-10 flex-shrink-0" onClick={sendMessage}>
            <Send className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  )
}

function SettingsView() {
  return (
    <ScrollArea className="h-full">
      <div className="space-y-4 p-4 pb-6">
        <Card>
          <CardContent className="p-4">
            <h3 className="mb-4 text-sm font-semibold">Account Settings</h3>
            <div className="space-y-4">
              <div>
                <label className="mb-1 block text-xs text-muted-foreground">Email</label>
                <Input type="email" defaultValue="ethan.carter@email.com" className="h-9 text-sm" />
              </div>
              <div>
                <label className="mb-1 block text-xs text-muted-foreground">Password</label>
                <Input type="password" defaultValue="••••••••" className="h-9 text-sm" />
              </div>
              <Button className="w-full" size="sm">
                Save Changes
              </Button>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <h3 className="mb-4 text-sm font-semibold">Notification Preferences</h3>
            <div className="space-y-3">
              {["Health Reminders", "Community Updates", "Chat Messages", "Challenge Alerts"].map((item) => (
                <div key={item} className="flex items-center justify-between">
                  <span className="text-sm">{item}</span>
                  <Button variant="outline" size="sm" className="h-7 bg-transparent text-xs">
                    On
                  </Button>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <h3 className="mb-4 text-sm font-semibold">Privacy</h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-sm">Profile Visibility</span>
                <Button variant="outline" size="sm" className="h-7 bg-transparent text-xs">
                  Public
                </Button>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm">Activity Sharing</span>
                <Button variant="outline" size="sm" className="h-7 bg-transparent text-xs">
                  Friends
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </ScrollArea>
  )
}

function DashboardView({ healthData }: { healthData: HealthData }) {
  const [activeCategory, setActiveCategory] = useState<"sleep" | "food" | "exercise">("sleep")

  const weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

  const sleepData = healthData.sleep
  const maxSleep = Math.max(...sleepData)

  const avgSleep = (sleepData.reduce((a, b) => a + b, 0) / sleepData.length).toFixed(1)
  const lastWeekAvg = (sleepData.slice(0, -1).reduce((a, b) => a + b, 0) / (sleepData.length - 1)).toFixed(1)
  const trend = (
    ((Number.parseFloat(avgSleep) - Number.parseFloat(lastWeekAvg)) / Number.parseFloat(lastWeekAvg)) *
    100
  ).toFixed(0)

  const badges = [
    {
      title: "Sleep Champion",
      description: "7 days of consistent sleep",
      color: "bg-sage-500/20",
      icon: Moon,
    },
    {
      title: "Healthy Eater",
      description: "Tracked 50 meals",
      color: "bg-orange-400/20",
      icon: Flame,
    },
    {
      title: "Active Achiever",
      description: "Completed 10 workouts",
      color: "bg-blue-400/20",
      icon: TrendingUp,
    },
  ]

  return (
    <ScrollArea className="h-full">
      <div className="space-y-4 p-4 pb-6">
        {/* Category Tabs */}
        <div className="flex gap-2 overflow-x-auto pb-2">
          {(["sleep", "food", "exercise"] as const).map((category) => (
            <Button
              key={category}
              variant={activeCategory === category ? "default" : "outline"}
              size="sm"
              className="h-8 flex-shrink-0 text-xs capitalize"
              onClick={() => setActiveCategory(category)}
            >
              {category}
            </Button>
          ))}
        </div>

        {/* Sleep Duration Card */}
        {activeCategory === "sleep" && (
          <>
            <Card>
              <CardContent className="p-4">
                <h3 className="mb-1 text-sm font-semibold">Sleep Duration</h3>
                <div className="mb-1 flex items-end gap-2">
                  <p className="text-4xl font-bold">{avgSleep}h</p>
                  <p
                    className={`mb-1 text-sm font-medium ${Number.parseFloat(trend) >= 0 ? "text-green-600" : "text-red-600"}`}
                  >
                    Last 7 Days {Number.parseFloat(trend) >= 0 ? "+" : ""}
                    {trend}%
                  </p>
                </div>

                {/* Chart */}
                <div className="mb-4 mt-6">
                  <div className="flex h-32 items-end justify-between gap-1">
                    {sleepData.map((hours, i) => (
                      <div key={i} className="flex flex-1 flex-col items-center gap-1">
                        <div className="flex h-full w-full items-end justify-center">
                          <div
                            className="relative w-full rounded-t-sm bg-primary/20"
                            style={{ height: `${(hours / maxSleep) * 100}%` }}
                          >
                            <div className="absolute inset-0 rounded-t-sm bg-gradient-to-t from-primary/40 to-primary/10" />
                          </div>
                        </div>
                        <span className="text-[10px] text-muted-foreground">{weekDays[i]}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Badges & Awards */}
            <div>
              <h3 className="mb-3 text-sm font-semibold">Badges & Awards</h3>
              <div className="grid grid-cols-2 gap-3">
                {badges.map((badge, i) => (
                  <Card key={i} className={badge.color}>
                    <CardContent className="flex flex-col items-center p-4 text-center">
                      <div className="mb-3 flex h-16 w-16 items-center justify-center rounded-full bg-white/50">
                        <badge.icon className="h-8 w-8 text-foreground" />
                      </div>
                      <p className="mb-1 text-xs font-semibold">{badge.title}</p>
                      <p className="text-[10px] text-muted-foreground">{badge.description}</p>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </div>

            {/* History */}
            <div>
              <h3 className="mb-3 text-sm font-semibold">History</h3>
              <Card>
                <CardContent className="space-y-3 p-3">
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full bg-blue-500/10">
                      <Moon className="h-5 w-5 text-blue-600" />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">Night Sleep</p>
                      <p className="text-xs text-muted-foreground">{sleepData[sleepData.length - 1]}h</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full bg-yellow-500/10">
                      <Sun className="h-5 w-5 text-yellow-600" />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-medium">Nap</p>
                      <p className="text-xs text-muted-foreground">1h 30m</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </>
        )}

        {/* Food Category */}
        {activeCategory === "food" && (
          <>
            <Card>
              <CardContent className="p-4">
                <h3 className="mb-1 text-sm font-semibold">Meals Tracked</h3>
                <div className="mb-1 flex items-end gap-2">
                  <p className="text-4xl font-bold">50</p>
                  <p className="mb-1 text-sm font-medium text-green-600">This month +12%</p>
                </div>
                <div className="mt-6 space-y-2">
                  {["Breakfast", "Lunch", "Dinner", "Snacks"].map((meal, i) => (
                    <div key={meal} className="flex items-center gap-3">
                      <span className="w-16 text-xs text-muted-foreground">{meal}</span>
                      <div className="h-6 flex-1 overflow-hidden rounded-full bg-muted">
                        <div
                          className="flex h-full items-center justify-end bg-orange-500 pr-2"
                          style={{ width: `${[85, 92, 78, 65][i]}%` }}
                        >
                          <span className="text-[10px] font-semibold text-white">{[17, 18, 16, 13][i]}</span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </>
        )}

        {/* Exercise Category */}
        {activeCategory === "exercise" && (
          <>
            <Card>
              <CardContent className="p-4">
                <h3 className="mb-1 text-sm font-semibold">Active Minutes</h3>
                <div className="mb-1 flex items-end gap-2">
                  <p className="text-4xl font-bold">210</p>
                  <p className="mb-1 text-sm font-medium text-green-600">This week +8%</p>
                </div>
                <div className="mt-6">
                  <div className="flex h-32 items-end justify-between gap-1">
                    {[25, 35, 28, 42, 30, 38, 45].map((mins, i) => (
                      <div key={i} className="flex flex-1 flex-col items-center gap-1">
                        <div className="flex h-full w-full items-end justify-center">
                          <div
                            className="w-full rounded-t-sm bg-blue-500/20"
                            style={{ height: `${(mins / 45) * 100}%` }}
                          />
                        </div>
                        <span className="text-[10px] text-muted-foreground">{weekDays[i]}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          </>
        )}
      </div>
    </ScrollArea>
  )
}
